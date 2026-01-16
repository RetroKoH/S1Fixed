using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace S1ObjectDefinitions.GHZ
{
	class WreckingBall : ObjectDefinition
	{
		private int[] labels = { 0, 1, 2 };		// Platform, Chain, Anchor
		private Sprite imgwreckingball;
		private List<Sprite> imgs = new List<Sprite>();

		public override void Init(ObjectData data)
		{
			imgwreckingball = ObjectHelper.MapASMToBmp(ObjectHelper.OpenArtFile("../artnem/GHZ Giant Ball.nem", CompressionType.Nemesis), "../_maps/GHZ Ball.asm", 1, 2);
			for (int i = 0; i < labels.Length; i++)
				imgs.Add(ObjectHelper.MapASMToBmp(ObjectHelper.OpenArtFile("../artnem/GHZ Swinging Platform.nem", CompressionType.Nemesis), "../_maps/Swinging Platforms (GHZ).asm", labels[i], i == 1 ? 0 : 1));
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new byte[] { 0, 1, 2, 3, 4, 5, 6, 7 }); }
		}

		public override string Name
		{
			get { return "Wrecking Ball"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override string SubtypeName(byte subtype)
		{
				return (subtype & 0x0F) + " links + ball";
		}

		public override Sprite Image
		{
			get { return imgwreckingball; }     // override the platform frame with the wrecking ball
        }

		public override Sprite SubtypeImage(byte subtype)
		{
				return imgwreckingball;     // override the platform frame with the wrecking ball
        }

		public override Sprite GetSprite(ObjectEntry obj)
		{
			int length = obj.SubType & 0x0F;
			List<Sprite> sprs = new List<Sprite>() { imgs[2] };
			int yoff = 16;
			for (int i = 0; i < length; i++)
			{
				Sprite tmp = new Sprite(imgs[1]);
				tmp.Offset(0, yoff);
				sprs.Add(tmp);
				yoff += 16;
			}
			yoff -= 8;
			Sprite tm2 = new Sprite(imgwreckingball);
			tm2.Offset(0, yoff);
			sprs.Add(tm2);
			return new Sprite(sprs.ToArray());
		}

		private PropertySpec[] customProperties = new PropertySpec[] {
			new PropertySpec("Chainlinks", typeof(int), "Extended", null, null, GetChainlinks, SetChainlinks),
		};

		public override PropertySpec[] CustomProperties
		{
			get
			{
				return customProperties;
			}
		}

		private static object GetChainlinks(ObjectEntry obj)
		{
			return obj.SubType & 0x0F;
		}

		private static void SetChainlinks(ObjectEntry obj, object value)
		{
			value = Math.Max(0, (Math.Min(0x0D, (int)value)));
			obj.SubType = (byte)((obj.SubType & ~0x0F) | (int)value);
		}
	}
}
