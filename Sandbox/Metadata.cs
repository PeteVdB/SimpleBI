using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Sandbox
{
    [XmlRoot("Metadata")]
    public class Metadata
    {
        [XmlElement("Attribute")]
        public List<Attribute> Attributes { get; set; }
    }

    public class Attribute
    {
        [XmlElement("Schema")]
        public string Schema { get; set; }

        [XmlElement("Table")]
        public string Table { get; set; }

        [XmlElement("Column")]
        public string Column { get; set; }

        [XmlElement("Function")]
        public string Function { get; set; }

        [XmlElement("SourceColumn")]
        public string SourceColumn { get; set; }

        [XmlElement("Ordinal_Position")]
        public string Ordinal_Position { get; set; }

        [XmlElement("IsNullable")]
        public bool IsNullable { get; set; }

        [XmlElement("IsBusinessKey")]
        public bool IsBusinessKey { get; set; }

        [XmlElement("DataType")]
        public string DataType { get; set; }

        [XmlElement("Character_maximum_length")]
        public int? Character_maximum_length { get; set; }

        [XmlElement("Numeric_Precision")]
        public int? Numeric_Precision { get; set; }

        [XmlElement("Numeric_Scale")]
        public int? Numeric_Scale { get; set; }

        [XmlElement("DateTime_Precision")]
        public int? DateTime_Precision { get; set; }
    }
}