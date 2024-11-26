using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace S1ObjectDefinitions.GHZ
{
	class SpikedPole : ObjectDefinition
	{
		private List<Sprite> imgs = new List<Sprite>();

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../artnem/GHZ Spiked Log.nem", CompressionType.Nemesis);
			for (int i = 0; i < 8; i++)
			{
				imgs.Add(ObjectHelper.MapASMToBmp(artfile, "../_maps/Spiked Pole Helix.asm", i, 2));
			}
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new byte[] { 0, 1, 2, 3, 4, 5, 6, 7 }); }
		}

		public override string Name
		{
			get { return "Helix of spikes on a pole"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override byte DefaultSubtype { get { return 0x7; } }

		public override string SubtypeName(byte subtype)
		{
			return Math.Min(0x8, (int)subtype+1) + " spikes";
		}

		public override Sprite Image
		{
			get { return imgs[0]; }
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return imgs[0];
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			List<Sprite> sprs = new List<Sprite>();
			int spikeoffset = 0x00;
			for (int i = 0; i < Math.Min(0x8, (int)obj.SubType+1); i++)
			{
				Sprite tmp = new Sprite(imgs[i & 7]);
				tmp.Offset(spikeoffset, 0);
				sprs.Add(tmp);
				spikeoffset += 0x10;
			}
			return new Sprite(sprs.ToArray());
		}

		private PropertySpec[] customProperties = new PropertySpec[] {
			new PropertySpec("Spikes", typeof(int), "Extended", null, null, GetSpikes, SetSpikes),
		};

		public override PropertySpec[] CustomProperties
		{
			get
			{
				return customProperties;
			}
		}

		private static object GetSpikes(ObjectEntry obj)
		{
			return Math.Min(0x8, (int)obj.SubType+1);
		}

		private static void SetSpikes(ObjectEntry obj, object value)
		{
			obj.SubType = (byte)(Math.Max(0x0, (Math.Min(0x7, (int)value))));
		}
	}
}
