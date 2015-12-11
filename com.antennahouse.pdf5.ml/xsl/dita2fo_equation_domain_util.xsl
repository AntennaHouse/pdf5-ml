<?xml version="1.0" encoding="UTF-8"?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: equation domain utility stylesheet
    Copyright © 2009-2015 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="2.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs ahf"
>

    <!-- External Dependencies
         dita2fo_message.xsl
         dita2fo_util.xsl
      -->

    <!-- 
        function:	return equation-block has automatic equation number
        param:	    equation-number
        return:	    xs:boolean
        note:		Check children is empty or white-space only content
    -->
    <xsl:function name="ahf:hasAutoEquationNumber" as="xs:boolean">
        <xsl:param name="prmEquationNumber" as="element()"/>
        <xsl:choose>
            <xsl:when test="$prmEquationNumber[contains(@class,' equation-d/equation-number ')]">
                <xsl:choose>
                    <xsl:when test="exists($prmEquationNumber/*)">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="string(normalize-space(string($prmEquationNumber)))">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="true()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1600,('%class'),(string($prmEquationNumber/@class)))"/>
                </xsl:call-template-->
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>