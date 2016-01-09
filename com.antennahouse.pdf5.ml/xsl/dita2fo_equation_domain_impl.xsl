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
        function:	equation-figure implementation
        param:	    
        return:	    
        note:		From the DITA 1.3 spec:
                    "When an <equation-figure> element has multiple direct child <mathml>, <image>, or <pre> elements, each child represents an alternative form of the equation.
                     Processors are free to choose the form or forms that they use in deliverables.When an <equation-figure> element has multiple direct child <mathml>, <image>, 
                     or <pre> elements, each child represents an alternative form of the equation. Processors are free to choose the form or forms that they use in deliverables.
                     For example, if there is both an image and MathML markup, an HTML-generating processor could output both the image reference and the MathML with appropriate
                     HTML @class or @id values to enable dynamic showing or hiding of one form or the other based on browser capability. All other direct-child elements of
                     <equation-figure> are treated normally.
                     For example, if there is both an image and MathML markup, an HTML-generating processor could output both the image reference and the MathML with appropriate
                     HTML @class or @id values to enable dynamic showing or hiding of one form or the other based on browser capability. All other direct-child elements of
                     <equation-figure> are treated normally."
                     
                     This is hard to implement in PDF plug-in. If an author want to write the equation-figure in above purpose, the contents should be identified by @delivaryTarget
                     conditional attribute such like @deliveryTarget="html".
                     
                     As a result the PDF plug-in does not do anything about above. Only calls next priority template (fig template) by xsl:next-match.
    -->
    <xsl:template match="*[contains(@class, ' equation-d/equation-figure ')]" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
        function:	equation-inline implementation
        param:	    
        return:	    
        note:		equation-inline is the specialization of ph element. 
                    The PDF plug-in only calls ph template by xsl:next-match.
    -->
    <xsl:template match="*[contains(@class, ' equation-d/equation-inline ')]" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
        function:	equation-block implementation
        param:	    
        return:	    fo:block
        note:		Generate single fo:block selecting appropriate equation in the child.
                    <equation-block> can have multiple equations as the each direct child elements.
                    ahf:getCandidateEquationBody will select most appropriate one from child elements.
                    Also <equation-block> can have multiple <equation-number>. But DITA 1.3 spec says that
                    they are used for conditional processing. 
                    So this template adopts equation-block/equation-number[1] as equation number.
    -->
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsEquationBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]" priority="2">
        <xsl:variable name="equationBlock" as="element()" select="."/>
        <xsl:variable name="candidateEquationNumber" as="element()?" select="$equationBlock/*[contains(@class,' equation-d/equation-number ')][1]"/>
        <xsl:variable name="hasNoEquationNumber" as="xs:boolean" select="ahf:hasNoEquationNumber($equationBlock)"/>
        <xsl:variable name="candidateEquationBody" as="node()*" select="ahf:getCandidateEquationBody($equationBlock) | $equationBlock/text()"/>
        <xsl:variable name="isInEquationFigure" as="xs:boolean" select="exists(ancestor::*[contains(@class,' equation-d/equation-figure ')])"/>
        <xsl:variable name="outputEquationAndNumber" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$pNumberEquationBlockUnconditionally">
                    <xsl:choose>
                        <xsl:when test="$isInEquationFigure and $hasNoEquationNumber">
                            <xsl:sequence select="not($pExcludeAutoNumberingFromEquationFigure)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="true()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="exists($candidateEquationNumber)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- generate equation and equation number-->
            <xsl:when test="$outputEquationAndNumber">
                <fo:block>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <!-- equation body -->
                    <fo:inline>
                        <xsl:apply-templates select="$candidateEquationBody"/>
                    </fo:inline>
                    <fo:leader>
                        <xsl:call-template name="getAttributeSet">
                            <xsl:with-param name="prmAttrSetName" select="'atsEquationLeader'"/>
                        </xsl:call-template>
                    </fo:leader>
                    <!-- equation-number -->
                    <xsl:choose>
                        <xsl:when test="exists($candidateEquationNumber)">
                            <xsl:apply-templates select="$candidateEquationNumber"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="generateAutoEquationNumber">
                                <xsl:with-param name="prmEquationBlock" tunnel="yes" select="$equationBlock"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:when>
            <!-- generate only equation -->
            <xsl:otherwise>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:apply-templates select="$candidateEquationBody"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        function:	Select candidate equation body
        param:	    element()*
        return:	    node()*
        note:		Select candidate equation node()
                    1. <mathml> element
                    2. MathML <img>
                    3. SVG container
                    4. Otherwise 1st defined one
                    The selection strategy is implementation dependent.
    -->
    <xsl:function name="ahf:getCandidateEquationBody" as="element()?">
        <xsl:param name="prmEquationBlock" as="element()"/>
        <xsl:variable name="prmEquation" as="element()*" select="$prmEquationBlock/*"/>
        <xsl:choose>
            <xsl:when test="$prmEquation[contains(@class,' mathml-d/mathml ')]">
                <xsl:sequence select="($prmEquation[contains(@class,' mathml-d/mathml ')])[1]"/>
            </xsl:when>
            <xsl:when test="$prmEquation[contains(@class,' topic/image ')][ends-with(string(@src),'.mml') or ends-with(string(@src),'.xml')]">
                <xsl:sequence select="($prmEquation[contains(@class,' topic/image ')][ends-with(string(@src),'.mml') or ends-with(string(@src),'.xml')])[1]"/>
            </xsl:when>
            <xsl:when test="$prmEquation[contains(@class,' svg-d/svg-container ')]">
                <xsl:sequence select="($prmEquation[contains(@class,' svg-d/svg-container ')])[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="($prmEquation[not(contains(@class, ' equation-d/equation-number '))])[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        function:	equation-number template
        param:	    prmEquationBlock
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
                <xsl:with-param name="prmVarName" select="'Equation_Number_Prefix'"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="ahf:isAutoEquationNumber(.)">
                    <xsl:call-template name="ahf:getAutoEquationNumber">
                        <xsl:with-param name="prmEquationNumber" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Equation_Number_Suffix'"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <!-- 
        function:	generate auto equation number for equation-block without equation-number
        param:	    prmEquationBlock
        return:	    fo:inline
        note:		
    -->
    <xsl:template name="generateAutoEquationNumber" as="element()">
        <xsl:param name="prmEquationBlock" tunnel="yes" required="yes" as="element()"/>
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsEquationNumber'"/>
                <xsl:with-param name="prmElem" select="$prmEquationBlock"/>
            </xsl:call-template>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Equation_Number_Prefix'"/>
                <xsl:with-param name="prmElem" select="$prmEquationBlock"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getAutoEquationNumber">
                <xsl:with-param name="prmEquationNumber" select="."/>
            </xsl:call-template>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Equation_Number_Suffix'"/>
                <xsl:with-param name="prmElem" select="$prmEquationBlock"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <!-- 
     function:	Generate equation-number
     param:		prmTopicRef, prmEquationNumber
     return:	Equation number string
     note:		If equation-block has no equation-number, equation-block is passed as $prmEquationNumber. 
     -->
    <xsl:template name="ahf:getAutoEquationNumber" as="xs:string">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:param name="prmEquationNumber" required="no" as="element()" select="."/>
        
        <xsl:variable name="equationBlock" as="element()" select="$prmEquationNumber/ancestor-or-self::*[contains(@class,' equation-d/equation-block ')][1]"/>
        <xsl:variable name="titlePrefix" as="xs:string">
            <xsl:choose>
                <xsl:when test="$pAddNumberingTitlePrefix">
                    <xsl:variable name="titlePrefixPart" select="ahf:genLevelTitlePrefixByCount($prmTopicRef,$cEquationBlockGroupingLevelMax)"/>
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
            <xsl:sequence select="$equationBlockNumberingMap//*[string(@id) eq $topicId]/@prev-count"/>
        </xsl:variable>
        
        <xsl:variable name="equationNumberCurrentAmount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$pNumberEquationBlockUnconditionally and not($pExcludeAutoNumberingFromEquationFigure)">
                    <xsl:sequence select="count($topic//*[contains(@class,' equation-d/equation-block ')]
                                                    [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                    [ahf:hasAutoEquationNumber(.) or ahf:hasNoEquationNumber(.)]
                                                    [. &lt;&lt; $equationBlock]|$equationBlock)"/>
                </xsl:when>
                <xsl:when test="$pNumberEquationBlockUnconditionally and $pExcludeAutoNumberingFromEquationFigure">
                    <xsl:variable name="equationBlockCountOutsideEquationFigure" as="xs:integer" 
                        select="count($topic//*[contains(@class,' equation-d/equation-block ')]
                                                [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                [ahf:hasNoEquationNumber(.) or ahf:hasAutoEquationNumber(.) ]
                                                [empty(ancestor::*[contains(@class,' equation-d/equation-figure ')])]
                                                [. &lt;&lt; $equationBlock])"/>
                    <xsl:variable name="equationBlockCountInsideEquationFigure" as="xs:integer"
                        select="count($topic//*[contains(@class,' equation-d/equation-block ')]
                                                [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                [ahf:hasEquationNumber(.) and ahf:hasAutoEquationNumber(.) ]
                                                [exists(ancestor::*[contains(@class,' equation-d/equation-figure ')])]
                                                [. &lt;&lt; $equationBlock])"/>
                    <xsl:sequence select="$equationBlockCountOutsideEquationFigure + $equationBlockCountInsideEquationFigure + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="count($topic//*[contains(@class,' equation-d/equation-block ')]
                                                    [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                    [ahf:hasAutoEquationNumber(.)]
                                                    [. &lt;&lt; $equationBlock]|$equationBlock)"/>
                </xsl:otherwise>
            </xsl:choose>
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