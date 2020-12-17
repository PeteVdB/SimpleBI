using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Sandbox
{
    class Program
    {
        static void Main(string[] args)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(Metadata));

            using (FileStream fileStream = new FileStream(@"C:\Source\SimpleBI\DB\Metadata\UCI.xml", FileMode.Open))
            {
                Metadata result = (Metadata)serializer.Deserialize(fileStream);
            }
        }
    }
}
