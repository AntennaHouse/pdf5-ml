<?xml version="1.0" encoding="UTF-8"?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: XML mention domain stylesheet
    Copyright © 2009-2016 Antenna House, Inc. All rights reserved.
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

    <!-- 
        function:	numcharref
        param:	    
        return:	    fo:inline
        note:		
    -->
    <xsl:template match="*[contains(@class, ' xml-d/numcharref ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="4">
        <xsl:sequence select="'atsNumCharRef'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/numcharref ')]" priority="4">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:call-template name="getVarValueAsText">
                <xsl:with-param name="prmVarName" select="'NumCharRef_Prefix'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVarValueAsText">
                <xsl:with-param name="prmVarName" select="'NumCharRef_Suffix'"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' xml-d/numcharref ')]" priority="4" mode="TEXT_ONLY">
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'NumCharRef_Prefix'"/>
        </xsl:call-template>
        <xsl:apply-templates mode="#current"/>
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'NumCharRef_Suffix'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
        function:	parameterentity
        param:	    
        return:	    fo:inline
        note:		
    -->
    <xsl:template match="*[contains(@class, ' xml-d/parameterentity ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="4">
        <xsl:sequence select="'atsParameterEntity'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/parameterentity ')]" priority="4">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsParameterEntityPrefix'"/>
                </xsl:call-template>
                <xsl:call-template name="getVarValueAsText">
                    <xsl:with-param name="prmVarName" select="'ParameterEntity_Prefix'"/>
                </xsl:call-template>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsParameterEntityBody'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsParameterEntitySuffix'"/>
                </xsl:call-template>
                <xsl:call-template name="getVarValueAsText">
                    <xsl:with-param name="prmVarName" select="'ParameterEntity_Suffix'"/>
                </xsl:call-template>
            </fo:inline>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/parameterentity ')]" priority="4" mode="TEXT_ONLY">
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'ParameterEntity_Prefix'"/>
        </xsl:call-template>
        <xsl:apply-templates mode="#current"/>
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'ParameterEntity_Suffix'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- 
        function:	textentity
        param:	    
        return:	    fo:inline
        note:		
    -->
    <xsl:template match="*[contains(@class, ' xml-d/textentity ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="4">
        <xsl:sequence select="'atsTextEntity'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/textentity ')]" priority="4">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTextEntityPrefix'"/>
                </xsl:call-template>
                <xsl:call-template name="getVarValueAsText">
                    <xsl:with-param name="prmVarName" select="'TextEntity_Prefix'"/>
                </xsl:call-template>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTextEntityBody'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTextEntitySuffix'"/>
                </xsl:call-template>
                <xsl:call-template name="getVarValueAsText">
                    <xsl:with-param name="prmVarName" select="'TextEntity_Suffix'"/>
                </xsl:call-template>
            </fo:inline>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/textentity ')]" priority="4" mode="TEXT_ONLY">
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'TextEntity_Prefix'"/>
        </xsl:call-template>
        <xsl:apply-templates mode="#current"/>
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'TextEntity_Suffix'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
        function:	xmlatt
        param:	    
        return:	    fo:inline
        note:		
    -->
    <xsl:template match="*[contains(@class, ' xml-d/xmlatt ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="4">
        <xsl:sequence select="'atsXmlAtt'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlatt ')]" priority="4">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsXmlAttPrefix'"/>
                </xsl:call-template>
                <xsl:call-template name="getVarValueAsText">
                    <xsl:with-param name="prmVarName" select="'XmlAtt_Prefix'"/>
                </xsl:call-template>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsXmlAttBody'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:inline>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlatt ')]" priority="4" mode="TEXT_ONLY">
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'XmlAtt_Prefix'"/>
        </xsl:call-template>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <!-- 
        function:	xmlelement
        param:	    
        return:	    fo:inline
        note:		
    -->
    <xsl:template match="*[contains(@class, ' xml-d/xmlelement ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="4">
        <xsl:sequence select="'atsXmlElement'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlelement ')]" priority="4">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsXmlElementPrefix'"/>
                </xsl:call-template>
                <xsl:call-template name="getVarValueAsText">
                    <xsl:with-param name="prmVarName" select="'XmlElement_Prefix'"/>
                </xsl:call-template>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsXmlElementBody'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsXmlElementSuffix'"/>
                </xsl:call-template>
                <xsl:call-template name="getVarValueAsText">
                    <xsl:with-param name="prmVarName" select="'XmlElement_Suffix'"/>
                </xsl:call-template>
            </fo:inline>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlelement ')]" priority="4" mode="TEXT_ONLY">
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'XmlElement_Prefix'"/>
        </xsl:call-template>
        <xsl:apply-templates mode="#current"/>
        <xsl:call-template name="getVarValueAsText">
            <xsl:with-param name="prmVarName" select="'XmlElement_Suffix'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
        function:	xmlnsname
        param:	    
        return:	    fo:inline
        note:		
    -->
    <xsl:template match="*[contains(@class, ' xml-d/xmlnsname ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="4">
        <xsl:sequence select="'atsXmlNsName'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlnsname ')]" priority="4">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlnsname ')]" priority="4" mode="TEXT_ONLY">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <!-- 
        function:	xmlpi
        param:	    
        return:	    fo:inline
        note:		
    -->
    <xsl:template match="*[contains(@class, ' xml-d/xmlpi ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="4">
        <xsl:sequence select="'atsXmlPi'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlpi ')]" priority="4">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' xml-d/xmlpi ')]" priority="4" mode="TEXT_ONLY">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

</xsl:stylesheet>