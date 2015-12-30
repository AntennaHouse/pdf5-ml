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
        note:		generate *SINGLE* fo:block selecting appropriate equation in the child.
                    <equation-block> can have multiple equations separated <equation-number>.
                    In this case all of the content of equation-number should be the same
                    because <equation-block> expresses only *SINGLE* equation.
                    This template adopts equation-block/equation-number[1] as equation number.
    -->
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsEquationBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]" as="element()">
        <xsl:variable name="equationBlock" as="element()" select="."/>
        <xsl:variable name="equationNumberAndBody" as="document-node()" select="ahf:divideEquation($equationBlock)"/>
        <xsl:variable name="candidateEquationNumber" as="element()?" select="($equationNumberAndBody/equation/equation-number)[1]/*"/>
        <xsl:variable name="isManualEquationNumber" as="xs:boolean" select="ahf:hasManualEquationNumber($candidateEquationNumber)"/>
        <xsl:variable name="isAutoEquationNumber" as="xs:boolean" select="not($isManualEquationNumber)"/>
        <xsl:variable name="candidateEquationBody" as="node()*" select="ahf:getCandidateEquationBody($equationNumberAndBody)"/>
        <xsl:variable name="isInEquationFigure" as="xs:boolean" select="exists(ancestor::*[contains(@class,' equation-d/equation-figure ')])"/>
        <xsl:choose>
            <!-- generate equation and equation number-->
            <xsl:when test="$isManualEquationNumber or ($pNumberEquationBlockUnconditionally and not($isInEquationFigure and $isAutoEquationNumber))">
                <fo:block>
                    <xsl:call-template name="ahf:getUnivAtts"/>
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
                            <xsl:apply-templates select="$candidateEquationNumber">
                                <xsl:with-param name="prmEquationBlock" tunnel="yes" select="$equationBlock"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            
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
        function:	Divide equation-block by equation-number
        param:	    prmEquationBlock
        return:	    document-node
        note:		empty equation will be automatically omitted
    -->
    <xsl:function name="ahf:divideEquation" as="document-node()">
        <xsl:param name="prmEquationBlock" as="element()"/>
        <xsl:document>
            <xsl:for-each-group select="$prmEquationBlock/node()" group-adjacent="ahf:getEquationGroupNumber($prmEquationBlock)">
                <xsl:variable name="currentGroup" as="node()*" select="current-group()"/>
                <xsl:variable name="currentEquationNumber" as="element()?" select="$currentGroup[contains(@class,' equation-d/equation-number ')][1]"/>
                <xsl:variable name="currentEquationBody" as="node()*" select="$currentGroup except (*[contains(@class,' equation-d/equation-number ')] | self::comment() | self::processing-instruction())"/>
                <xsl:variable name="currentEquationBodyWoWs" as="node()*" select="ahf:getFirstEquationPart($currentEquationBody)"/>
                <xsl:choose>
                    <xsl:when test="empty($currentEquationNumber) and (every $t in $currentEquationBody satisfies (($t/self::text() and not(string(normalize-space(string($t)))))))"/>
                    <xsl:otherwise>
                        <equation>
                            <equation-number>
                                <xsl:sequence select="$currentEquationNumber"/>
                            </equation-number>
                            <equation-body>
                                <xsl:sequence select="$currentEquationBodyWoWs"/>
                            </equation-body>
                        </equation>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>    
        </xsl:document>
    </xsl:function>

    <!-- 
        function:	Select candidate equation body
        param:	    document-node() (Output of ahf:divideEquation)
        return:	    node()*
        note:		Select candidate equation node()
                    1. <mathml> element
                    2. MathML <img>
                    3. SVG container
                    4. Otherwise 1st defined one
                    The selection strategy is implementation dependent.
    -->
    <xsl:function name="ahf:getCandidateEquationBody" as="node()*">
        <xsl:param name="prmEquation" as="document-node()"/>
        <xsl:choose>
            <xsl:when test="$prmEquation/equation/equation-body/node()[1][contains(@class,' mathml-d/mathml ')]">
                <xsl:sequence select="($prmEquation/equation/equation-body/node()[1][contains(@class,' mathml-d/mathml ')])[1]"/>
            </xsl:when>
            <xsl:when test="$prmEquation/equation/equation-body/node()[1][contains(@class,' topic/image ')][ends-with(string(@src),'.mml') or ends-with(string(@src),'.xml')]">
                <xsl:sequence select="($prmEquation/equation/equation-body/node()[1][contains(@class,' topic/image ')][ends-with(string(@src),'.mml') or ends-with(string(@src),'.xml')])[1]"/>
            </xsl:when>
            <xsl:when test="$prmEquation/equation/equation-body/node()[1][contains(@class,' svg-d/svg-container  ')]">
                <xsl:sequence select="($prmEquation/equation/equation-body/node()[1][contains(@class,' svg-d/svg-container ')])[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$prmEquation/equation/equation-body[1]/node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        function:	Get first body of equation
        param:	    node()*
        return:	    node()*
        note:		Return equation body first
    -->
    <xsl:function name="ahf:getFirstEquationPart" as="node()*">
        <xsl:param name="prmEquationBody" as="node()*"/>
        <xsl:variable name="firstNode" as="node()" select="$prmEquationBody[1]"/>
        <xsl:choose>
            <xsl:when test="$firstNode[self::text()][not(string(normalize-space(string(.))))]">
                <xsl:sequence select="$prmEquationBody except $firstNode"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$prmEquationBody"/>
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
                <xsl:with-param name="prmVarName" select="'Equatuion_Number_Prefix'"/>
                <xsl:with-param name="prmElem" select="$prmEquationBlock"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getAutoEquationNumber">
                <xsl:with-param name="prmEquationNumber" select="."/>
            </xsl:call-template>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'Equatuion_Number_Suffix'"/>
                <xsl:with-param name="prmElem" select="$prmEquationBlock"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <!-- 
     function:	Generate equation-number
     param:		prmTopicRef, prmEquationNumber, prmEquationBlock
     return:	Equation number string
     note:		
     -->
    <xsl:template name="ahf:getAutoEquationNumber" as="xs:string">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:param name="prmEquationNumber" required="no" as="element()" select="."/>
        <xsl:param name="prmEquationBlock" tunnel="yes" required="yes" as="element()"/>
        
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
        
        <xsl:variable name="topic" as="element()" select="$prmEquationBlock/ancestor::*[contains(@class, ' topic/topic ')][position() eq last()]"/>
        
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
            <xsl:sequence select="count($topic//*[contains(@class,' equation-d/equation-block ')][ahf:hasAutoEquationNumber(.)][. &lt;&lt; $prmEquationBlock]|$prmEquationBlock)"/>
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