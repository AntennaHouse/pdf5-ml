<?xml version="1.0" encoding="UTF-8"?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: equation domain implementation stylesheet
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
         dita2fo_style_get.xsl
         dita2fo_message.xsl
         dita2fo_util.xsl
      -->

    <xsl:variable name="cEquationNumberTitle" select="ahf:getVarValue('Equation_Number_Title')" as="xs:string"/>

    <!-- 
        function:	equation-block implementation
        param:	    
        return:	    fo:block
        note:		generate fo:block per equation-number
    -->
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsEquationBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]" as="element()">
        <xsl:variable name="equationBlock" as="element()" select="."/>
        <xsl:choose>
            <xsl:when test="exists(*[contains(@class,' equation-d/equation-number ')])">
                <fo:block>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:for-each-group select="node()" group-adjacent="ahf:getEquationGroupNumber(.)">
                        <xsl:variable name="currentGroup" as="node()*" select="current-group()"/>
                        <xsl:choose>
                            <xsl:when test="$currentGroup[1][contains(@class,' equation-d/equation-number ')]">
                                <fo:block>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmElem" select="$equationBlock"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="ahf:getUnivAtts">
                                        <xsl:with-param name="prmElement" select="$currentGroup[1]"/>
                                    </xsl:call-template>
                                    <!-- equation body -->
                                    <fo:inline>
                                        <xsl:apply-templates select="$currentGroup[position() gt 1]"/>
                                    </fo:inline>
                                    <fo:leader>
                                        <xsl:call-template name="getAttributeSet">
                                            <xsl:with-param name="prmAttrSetName" select="'atsEquationLeader'"/>
                                        </xsl:call-template>
                                    </fo:leader>
                                    <!-- equation-number -->
                                    <xsl:apply-templates select="$currentGroup[1]"/>
                                </fo:block>                        
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- first equation that has no equation-number -->
                                <fo:block>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmElem" select="$equationBlock"/>
                                    </xsl:call-template>
                                    <!-- equation body -->
                                    <fo:inline>
                                        <xsl:apply-templates select="$currentGroup"/>
                                    </fo:inline>
                                </fo:block>                        
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
        function:	grouping equation-block by equation-number
        param:	    
        return:	    xs:integer
        note:		group with preceding-sibling::equation-number
    -->
    <xsl:function name="ahf:getEquationGroupNumber" as="xs:integer">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:choose>
            <xsl:when test="$prmNode[contains(@class, ' equation-d/equation-number ')]">
                <xsl:sequence select="count($prmNode | $prmNode/preceding-sibling::*[contains(@class, ' equation-d/equation-number ')])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="count($prmNode/preceding-sibling::*[contains(@class, ' equation-d/equation-number ')])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        function:	equation-number template
        param:	    
        return:	    fo:inline
        note:		empty equation-number will be automatically numbered, otherwise only apply templates to child node
    -->
    <xsl:template match="*[contains(@class, ' equation-d/equation-number ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsEquationNumber'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-number ')]" as="element()" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Equatuion_Number_Prefix'"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="ahf:hasAutoEquationNumber(.)">
                    <xsl:call-template name="ahf:getAutoEquationNumber">
                        <xsl:with-param name="prmEquationNumber" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Equatuion_Number_Suffix'"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	Generate equation-number title prefix
     param:		prmTopicRef, prmEquationNumber
     return:	Table title prefix string
     note:		
     -->
    <xsl:template name="ahf:getAutoEquationNumber" as="xs:string">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:param name="prmEquationNumber" required="no" as="element()" select="."/>
        
        <xsl:variable name="titlePrefix" as="xs:string">
            <xsl:choose>
                <xsl:when test="$pAddNumberingTitlePrefix">
                    <xsl:variable name="titlePrefixPart" select="ahf:genLevelTitlePrefixByCount($prmTopicRef,$cEquationNumberGroupingLevelMax)"/>
                    <xsl:choose>
                        <xsl:when test="string($titlePrefixPart)">
                            <xsl:sequence select="concat($titlePrefixPart,$cTitleSeparator)"/>        
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$titlePrefixPart"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="topic" as="element()" select="$prmEquationNumber/ancestor::*[contains(@class, ' topic/topic ')][position() eq last()]"/>
        
        <xsl:variable name="equationNumberPreviousAmount" as="xs:integer">
            <xsl:variable name="topicId" as="xs:string">
                <xsl:variable name="idAttr" as="attribute()*">
                    <xsl:call-template name="ahf:getIdAtts">
                        <xsl:with-param name="prmElement" select="$topic"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:sequence select="string($idAttr[1])"/>
            </xsl:variable>
            <!--xsl:message select="'[equationNumberPreviousAmount] id=',$topicId"/-->
            <xsl:sequence select="$equationNumberingMap//*[string(@id) eq $topicId]/@prev-count"/>
        </xsl:variable>
        
        <xsl:variable name="equationNumberCurrentAmount" as="xs:integer">
            <xsl:sequence select="count($topic//*[contains(@class,' equation-d/equation-number ')][ahf:hasAutoEquationNumber(.)][. &lt;&lt; $prmEquationNumber]|$prmEquationNumber)"/>
        </xsl:variable>
        <xsl:variable name="equationNumber" select="$equationNumberPreviousAmount + $equationNumberCurrentAmount" as="xs:integer"/>
        
        <xsl:sequence select="concat($cEquationNumberTitle,$titlePrefix,string($equationNumber))"/>
    </xsl:template>
    
    <xsl:function name="ahf:getGetAutoEquationNumber" as="xs:string">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmEquationNumber" as="element()"/>
        
        <xsl:call-template name="ahf:getAutoEquationNumber">
            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
            <xsl:with-param name="prmEquationNumber" select="$prmEquationNumber"/>
        </xsl:call-template>
    </xsl:function>

</xsl:stylesheet>