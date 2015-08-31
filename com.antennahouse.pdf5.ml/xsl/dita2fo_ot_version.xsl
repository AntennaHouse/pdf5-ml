<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to XSL-FO Stylesheet
DITA-OT Version Utility Templates
**************************************************************
File Name : dita2fo_ot_version.xsl
**************************************************************
Copyright © 2009 2014 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->

<xsl:stylesheet version="2.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" >
    
    <!-- 
     function:	Compare DITA-OT version.
     param:		prmVersion1: Version 1
                prmVersion2: Version 2 
     return:	xs:integer?
                -1: Version 1 < Version 2
                 0: Version 1 = Version 2
                 1: Version 1 > Version 2
                 (): Error
     note:      
    -->
    <xsl:function name="ahf:compareOtVersion" as="xs:integer?">
        <xsl:param name="prmVer1" as="xs:string"/>
        <xsl:param name="prmVer2" as="xs:string"/>
        <xsl:variable name="ver1Seq" as="xs:string*">
            <xsl:analyze-string select="$prmVer1" regex="[\.]">
                <xsl:matching-substring/>
                <xsl:non-matching-substring>
                    <xsl:sequence select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="ver2Seq" as="xs:string*">
            <xsl:analyze-string select="$prmVer2" regex="[\.]">
                <xsl:matching-substring/>
                <xsl:non-matching-substring>
                    <xsl:sequence select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="ahf:compareOtVersionNo($ver1Seq,$ver2Seq)"/>
    </xsl:function>
    
    <!-- 
     function:	Compare DITA-OT version No.
     param:		prmVersion1: Version 1
                prmVersion2: Version 2 
     return:	xs:integer?
                -1: Version 1 < Version 2
                 0: Version 1 = Version 2
                 1: Version 1 > Version 2
                 (): Error
     note:      
    -->
    <xsl:function name="ahf:compareOtVersionNo" as="xs:integer?">
        <xsl:param name="prmVer1" as="xs:string*"/>
        <xsl:param name="prmVer2" as="xs:string*"/>
        
        <xsl:choose>
            <xsl:when test="exists($prmVer1[1]) and exists($prmVer2[1])">
                <xsl:variable name="verNo1" as="xs:integer?" select="ahf:getOtVersionNo($prmVer1[1])"/>
                <xsl:variable name="verNo2" as="xs:integer?" select="ahf:getOtVersionNo($prmVer2[1])"/>
                <xsl:choose>
                    <xsl:when test="exists($verNo1) and exists($verNo2)">
                        <xsl:choose>
                            <xsl:when test="$verNo1 gt $verNo2">
                                <xsl:sequence select="1"/>
                            </xsl:when>
                            <xsl:when test="$verNo1 lt $verNo2">
                                <xsl:sequence select="-1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="exists($prmVer1[position() gt 1]) or exists($prmVer2[position() gt 1])">
                                        <xsl:sequence select="ahf:compareOtVersionNo($prmVer1[position() gt 1],$prmVer2[position() gt 1])"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="0"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="exists($prmVer1[1]) and empty($prmVer2[1])">
                <xsl:sequence select="ahf:compareOtVersion($prmVer1[1],'0')"/>
            </xsl:when>
            <xsl:when test="empty($prmVer1[1]) and exists($prmVer2[1])">
                <xsl:sequence select="ahf:compareOtVersion('0',$prmVer2[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Get OT version number.
     param:		prmVersionNo
     return:	xs:integer?
     note:      
    -->
    <xsl:function name="ahf:getOtVersionNo" as="xs:integer?">
        <xsl:param name="prmVerNo" as="xs:string"/>
        <xsl:variable name="verNo" as="xs:string" select="replace($prmVerNo,'^M([0-9+])','$1')"/>
        <xsl:choose>
            <xsl:when test="$verNo castable as xs:integer">
                <xsl:sequence select="xs:integer($verNo)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>