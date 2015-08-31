<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: History id generation template
Copyright © 2014 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf">
    
    <!-- 
     function:	Generate id using element history (hierarchy)
     param:	    prmElem
     return:	id string
     note:		Newly coded to avoid using generate-id() function.
                2014-09-13 t.makita
     -->
    <xsl:function name="ahf:generateHistoryId" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getHistoryStr($prmElem)"/>
    </xsl:function>
    
    <!-- 
     function:    Generate element history (hierarchy) string
     param:       prmElem
     return:      xs:string
     note:        Fixed bug for non well-formed (well-balanced) tree.
                  2014-08-29 t.makita
     -->
    <xsl:function name="ahf:getHistoryStr" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="ancestorElem" as="element()+" select="$prmElem/ancestor-or-self::*"/>
        <xsl:variable name="historyStr" as="xs:string*">
            <xsl:for-each select="$ancestorElem">
                <xsl:variable name="elem" select="."/>
                <xsl:variable name="name" as="xs:string" select="name()"/>
                <xsl:sequence select="if (position() gt 1) then '.' else ''"/>
                <xsl:sequence select="local-name()"/>
                <xsl:sequence select="if (exists($elem/parent::*) or exists($elem/preceding-sibling::*|$elem/following-sibling::*)) then string(count($elem/preceding-sibling::*[name() eq $name]) + 1) else ''"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($historyStr,'')"/>
    </xsl:function>

    <xsl:function name="ahf:getHistoryStrWithPi" as="xs:string">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:variable name="ancestorElemOrPi" as="node()+" select="$prmNode/ancestor-or-self::* | $prmNode/ancestor-or-self::processing-instruction()"/>
        <xsl:variable name="historyStr" as="xs:string*">
            <xsl:for-each select="$ancestorElemOrPi">
                <xsl:variable name="elem" select="."/>
                <xsl:variable name="name" as="xs:string" select="name()"/>
                <xsl:sequence select="if (position() gt 1) then '.' else ''"/>
                <xsl:sequence select="if (. instance of element()) then local-name() else name()"/>
                <xsl:sequence select="if (exists($elem/parent::*) or exists($elem/preceding-sibling::*|$elem/following-sibling::*)) then string(count($elem/preceding-sibling::*[name() eq $name]) + 1) else ''"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($historyStr,'')"/>
    </xsl:function>

</xsl:stylesheet>