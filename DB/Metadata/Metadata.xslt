<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/*">
     <table><xsl:apply-templates select="Attribute"/></table>
 </xsl:template>

 <xsl:template match="Attribute[1]">
  <tr><xsl:apply-templates select="*" mode="header"/></tr>
  <xsl:call-template name="standardRow"/>
 </xsl:template>
  
 <xsl:template match="Attribute" name="standardRow">
  <tr><xsl:apply-templates select="*"/></tr>
 </xsl:template>

 <xsl:template match="Attribute/*">
  <td><xsl:apply-templates select="node()"/></td>
 </xsl:template>

 <xsl:template match="Attribute/*" mode="header">
  <th><xsl:value-of select="name()"/></th>
 </xsl:template>
</xsl:stylesheet>
