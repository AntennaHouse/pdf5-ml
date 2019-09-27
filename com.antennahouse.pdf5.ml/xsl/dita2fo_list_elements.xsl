<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: List related elements stylesheet
Copyright © 2009-2019 Antenna House, Inc. All rights reserved.
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
 exclude-result-prefixes="xs ahf"
>
    
    <!-- 
     function:  ol template
     param:	    
     return:    Numbered list (fo:list-block)
     note:      Call "processOl" for overriding from other plug-ins.
                2015-08-25 t.makita
                Add support for floating left figure.
                Generate fo:list-blck per li.
                2019-05-08 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ol ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsOl'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ol ')]">
        <xsl:call-template name="processOl"/>
    </xsl:template>
    
    <xsl:template name="processOl">
        <xsl:variable name="hasFloatFigLeft" as="xs:boolean" select="exists(*[contains(@class,' topic/li ')]//*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = 'left'])"/>
        <!-- Prefix of ol -->
        <xsl:variable name="olNumberFormat" as="xs:string+">
            <xsl:call-template name="getVarValueWithLangAsStringSequence">
                <xsl:with-param name="prmVarName" select="'Ol_Number_Formats'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="numberFormat" select="ahf:getOlNumberFormat(.,$olNumberFormat)" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$hasFloatFigLeft">
                <fo:wrapper>
                    <xsl:call-template name="ahf:getIdAtts">
                        <xsl:with-param name="prmElement" select="."/>
                    </xsl:call-template>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmNumberFormat" tunnel="yes" select="$numberFormat"/>
                        <xsl:with-param name="prmHasFloatFigLeft" tunnel="yes" select="$hasFloatFigLeft"/>
                    </xsl:apply-templates>
                </fo:wrapper>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-block>
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmNumberFormat" tunnel="yes" select="$numberFormat"/>
                        <xsl:with-param name="prmHasFloatFigLeft" tunnel="yes" select="$hasFloatFigLeft"/>
                    </xsl:apply-templates>
                </fo:list-block>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not($pDisplayFnAtEndOfTopic)">
            <xsl:call-template name="makeFootNote">
                <xsl:with-param name="prmElement"  select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:  ol/li template
     param:	    
     return:    Numbered list (fo:list-item)
     note:      Add consideration for stepsection.
                (2011-10-24 t.makita)
                Call "processOlLi" for overriding from other plug-ins.
                2015-08-25 t.makita
                Implement GET_CONTENT mode to prevent missing required parameter in processOlLi.
                2019-09-27 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ol ')]/*[contains(@class,' topic/li ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:variable name="hasFloatFigLeft" as="xs:boolean" select="exists(parent::*/*[contains(@class,' topic/li ')]//*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = 'left'])"/>
        <xsl:sequence select="'atsOlItem'"/>
        <xsl:if test="$hasFloatFigLeft">
            <xsl:sequence select="'atsOlItemClearNone'"/>
            <xsl:sequence select="'atsOlItemSpaceBeforeZero'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/ol ')]/*[contains(@class,' topic/li ')]">
        <xsl:param name="prmGetContent" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmGetContent">
                <xsl:call-template name="processOlLiGetContent"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processOlLi"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="processOlLiGetContent">
        <fo:inline>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <xsl:template name="processOlLi">
        <xsl:param name="prmNumberFormat" tunnel="yes" required="yes" as="xs:string"/>
        <xsl:param name="prmHasFloatFigLeft" tunnel="yes" required="yes" as="xs:boolean"/>

        <xsl:variable name="li" as="element()" select="."/>
        <xsl:variable name="ol" as="element()" select="$li/parent::*"/>
        <xsl:choose>
            <xsl:when test="$prmHasFloatFigLeft">
                <xsl:variable name="hasFloatFig" as="xs:boolean" select="exists(descendant::*[ahf:isFloatFigure(.)])"/>
                <!-- Gnerate fo:list-block for each step -->
                <fo:block>
                    <!-- Defaults clear='both' -->
                    <xsl:call-template name="getAttributeSet">
                        <xsl:with-param name="prmAttrSetName" select="'atsOlItemClearBoth atsOlItemSpaceBefore'"/>
                    </xsl:call-template>
                    <!-- Get clear attribute -->
                    <xsl:call-template name="ahf:getClearAtts"/>
                    <!-- Pull info/floatfig -->
                    <xsl:for-each select="descendant::*[ahf:isFloatFigure(.)]">
                        <xsl:choose>
                            <xsl:when test="ahf:getFloatSpec(.) = ('left','right')">
                                <xsl:call-template name="processFloatFigLR"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="processFloatFigNone"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <fo:list-block>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmElem" select="$ol"/>
                        </xsl:call-template>
                        <xsl:call-template name="ahf:getLocalizationAtts">
                            <xsl:with-param name="prmElement" select="$ol"/>
                        </xsl:call-template>
                        <xsl:call-template name="ahf:getClearAtts">
                            <xsl:with-param name="prmElement" select="$ol"/>
                        </xsl:call-template>
                        <xsl:copy-of select="ahf:getFoStyleAndProperty($ol)"/>
                        <fo:list-item>
                            <!-- Set list-item attribute. -->
                            <xsl:call-template name="getAttributeSetWithLang"/>
                            <xsl:call-template name="ahf:getUnivAtts"/>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                            <fo:list-item-label end-indent="label-end()"> 
                                <fo:block>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsOlLabel'"/>
                                    </xsl:call-template>
                                    <xsl:number format="{$prmNumberFormat}" value="count(preceding-sibling::*[contains(@class,' topic/li ')][not(contains(@class,' task/stepsection '))]) + 1"/>
                                </fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="body-start()">
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsOlBody'"/>
                                </xsl:call-template>
                                <fo:block>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsP'"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates/>
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    </fo:list-block>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-item>
                    <!-- Set list-item attribute. -->
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <fo:list-item-label end-indent="label-end()"> 
                        <fo:block>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsOlLabel'"/>
                            </xsl:call-template>
                            <xsl:number format="{$prmNumberFormat}" value="count(preceding-sibling::*[contains(@class,' topic/li ')][not(contains(@class,' task/stepsection '))]) + 1"/>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="body-start()">
                        <fo:block>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsP'"/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:  floatfig template
     param:     
     return:    none
     note:      Ignore if exists left float figure.
     -->
    <xsl:template match="*[contains(@class,' topic/ol ')][exists(*[contains(@class,' topic/li ')]//*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = 'left'])]//*[ahf:isFloatFigure(.)]" priority="4"/>
    
    <!-- 
     function:  Get ol number format
     param:     prmOl, prmOlNumberFormat
     return:    Number format string
     note:      Count ol in entry/note independently.
                2015-06-03 t.makita
     -->
    <xsl:function name="ahf:getOlNumberFormat" as="xs:string">
        <xsl:param name="prmOl" as="element()"/>
        <xsl:param name="prmOlNumberFormat" as="xs:string+"/>
        
        <xsl:variable name="olNumberFormatCount" as="xs:integer" select="count($prmOlNumberFormat)"/>
        <xsl:variable name="olNestLevel" select="ahf:countOl($prmOl,0)" as="xs:integer"/>
        <xsl:variable name="formatOrder" as="xs:integer">
            <xsl:variable name="tempFormatOrder" as="xs:integer" select="$olNestLevel mod $olNumberFormatCount"/>
            <xsl:sequence select="if ($tempFormatOrder eq 0) then $olNumberFormatCount else $tempFormatOrder"/>
        </xsl:variable>
        <xsl:sequence select="$prmOlNumberFormat[$formatOrder]"/>
    </xsl:function>
    
    <xsl:function name="ahf:countOl" as="xs:integer">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:param name="prmCount" as="xs:integer"/>
    
        <xsl:variable name="count" select="if ($prmElement[contains(@class, ' topic/ol ')]) then ($prmCount+1) else $prmCount"/>
        <xsl:choose>
            <xsl:when test="$prmElement[ahf:seqContains(@class, (' topic/entry ',' topic/stentry '))]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="$prmElement[contains(@class, ' topic/note ')]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="$prmElement[contains(@class, ' topic/topic ')]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="$prmElement/parent::*">
                <xsl:sequence select="ahf:countOl($prmElement/parent::*, $count)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$count"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:  ul template
     param:	    
     return:	Unordered list (fo:list-block)
     note:      Call "processUl" for overriding from other plug-ins.
                2015-08-25 t.makita
                Add support for floating left figure.
                Generate fo:list-blck per li.
                2019-05-08 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ul ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsUl'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ul ')]">
        <xsl:call-template name="processUl"/>
    </xsl:template>
    
    <xsl:template name="processUl">
        <xsl:variable name="hasFloatFigLeft" as="xs:boolean" select="exists(*[contains(@class,' topic/li ')]//*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = 'left'])"/>
        <!-- Ul bullet -->
        <xsl:variable name="ulLabelChars" as="xs:string+">
            <xsl:call-template name="getVarValueWithLangAsStringSequence">
                <xsl:with-param name="prmVarName" select="'Ul_Label_Chars'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ulLabelChar" select="ahf:getUlLabelChar(.,$ulLabelChars)" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$hasFloatFigLeft">
                <fo:wrapper>
                    <xsl:call-template name="ahf:getIdAtts">
                        <xsl:with-param name="prmElement" select="."/>
                    </xsl:call-template>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmUlLabelChar" tunnel="yes" select="$ulLabelChar"/>
                        <xsl:with-param name="prmHasFloatFigLeft" tunnel="yes" select="$hasFloatFigLeft"/>
                    </xsl:apply-templates>
                </fo:wrapper>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-block>
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmUlLabelChar" tunnel="yes" select="$ulLabelChar"/>
                        <xsl:with-param name="prmHasFloatFigLeft" tunnel="yes" select="$hasFloatFigLeft"/>
                    </xsl:apply-templates>
                </fo:list-block>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not($pDisplayFnAtEndOfTopic)">
            <xsl:call-template name="makeFootNote">
                <xsl:with-param name="prmElement"  select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:  ul/li template
     param:   
     return:    Unordered list (fo:list-item)
     note:      Call "processUlLi" for overriding from other plug-ins.
                2015-08-25 t.makita
                Add support for floating left figure.
                Generate fo:list-blck per li.
                2019-05-08 t.makita
                Implement GET_CONTENT mode to prevent missing required parameter in processUlLi.
                2019-09-27 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ul ')]/*[contains(@class,' topic/li ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:variable name="hasFloatFigLeft" as="xs:boolean" select="exists(parent::*/*[contains(@class,' topic/li ')]//*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = 'left'])"/>
        <xsl:sequence select="'atsUlItem'"/>
        <xsl:if test="$hasFloatFigLeft">
            <xsl:sequence select="'atsUlItemClearNone'"/>
            <xsl:sequence select="'atsUlItemSpaceBeforeZero'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ul ')]/*[contains(@class,' topic/li ')]">
        <xsl:param name="prmGetContent" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmGetContent">
                <xsl:call-template name="processUlLiGetContent"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processUlLi"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="processUlLiGetContent">
        <fo:inline>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>    

    <xsl:template name="processUlLi">
        <xsl:param name="prmUlLabelChar" tunnel="yes" required="yes" as="xs:string"/>
        <xsl:param name="prmHasFloatFigLeft" tunnel="yes" required="yes" as="xs:boolean"/>
        
        <xsl:variable name="li" as="element()" select="."/>
        <xsl:variable name="ul" as="element()" select="$li/parent::*"/>
        <xsl:choose>
            <xsl:when test="$prmHasFloatFigLeft">
                <xsl:variable name="hasFloatFig" as="xs:boolean" select="exists(descendant::*[ahf:isFloatFigure(.)])"/>
                <!-- Gnerate fo:list-block for each step -->
                <fo:block>
                    <!-- Defaults clear='both' -->
                    <xsl:call-template name="getAttributeSet">
                        <xsl:with-param name="prmAttrSetName" select="'atsUlItemClearBoth atsUlItemSpaceBefore'"/>
                    </xsl:call-template>
                    <!-- Get clear attribute -->
                    <xsl:call-template name="ahf:getClearAtts"/>
                    <!-- Pull info/floatfig -->
                    <xsl:for-each select="descendant::*[ahf:isFloatFigure(.)]">
                        <xsl:choose>
                            <xsl:when test="ahf:getFloatSpec(.) = ('left','right')">
                                <xsl:call-template name="processFloatFigLR"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="processFloatFigNone"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <fo:list-block>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmElem" select="$ul"/>
                        </xsl:call-template>
                        <xsl:call-template name="ahf:getLocalizationAtts">
                            <xsl:with-param name="prmElement" select="$ul"/>
                        </xsl:call-template>
                        <xsl:call-template name="ahf:getClearAtts">
                            <xsl:with-param name="prmElement" select="$ul"/>
                        </xsl:call-template>
                        <xsl:copy-of select="ahf:getFoStyleAndProperty($ul)"/>
                        <fo:list-item>
                            <xsl:call-template name="getAttributeSetWithLang"/>
                            <xsl:call-template name="ahf:getUnivAtts"/>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                            <fo:list-item-label end-indent="label-end()"> 
                                <fo:block>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsUlLabel'"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="$prmUlLabelChar"/>
                                </fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="body-start()">
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsUlBody'"/>
                                </xsl:call-template>
                                <fo:block>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsP'"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates/>
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    </fo:list-block>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-item>
                    <xsl:call-template name="getAttributeSetWithLang"/>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <fo:list-item-label end-indent="label-end()"> 
                        <fo:block>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsUlLabel'"/>
                            </xsl:call-template>
                            <xsl:value-of select="$prmUlLabelChar"/>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="body-start()">
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsUlBody'"/>
                        </xsl:call-template>
                        <fo:block>
                            <xsl:call-template name="getAttributeSetWithLang">
                                <xsl:with-param name="prmAttrSetName" select="'atsP'"/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:  floatfig template
     param:     
     return:    none
     note:      Ignore if exists left float figure.
     -->
    <xsl:template match="*[contains(@class,' topic/ul ')][exists(*[contains(@class,' topic/li ')]//*[ahf:isFloatFigure(.)][ahf:getFloatSpec(.) = 'left'])]//*[ahf:isFloatFigure(.)]" priority="4"/>
    
    <!-- 
     function:  Get ul label char
     param:     prmUl, prmUlLabelChars
     return:    Label char string
     note:      Count ul in entry/note independently.
                2019-05-08 t.makita
     -->
    <xsl:function name="ahf:getUlLabelChar" as="xs:string">
        <xsl:param name="prmUl" as="element()"/>
        <xsl:param name="prmUlLabelChars" as="xs:string+"/>
        
        <xsl:variable name="ulLabelCharsCount" as="xs:integer" select="count($prmUlLabelChars)"/>
        <xsl:variable name="ulNestLevel" select="ahf:countUl($prmUl,0)" as="xs:integer"/>
        <xsl:variable name="ulIndex" as="xs:integer">
            <xsl:variable name="tempUlIndex" as="xs:integer" select="$ulNestLevel mod $ulLabelCharsCount"/>
            <xsl:sequence select="if ($tempUlIndex eq 0) then $ulLabelCharsCount else $tempUlIndex"/>
        </xsl:variable>
        <xsl:sequence select="$prmUlLabelChars[$ulIndex]"/>
    </xsl:function>
    
    <!-- 
     function:  Count ul nesting level
     param:     prmElem, prmCount
     return:    xs:integer
     note:      A nesting level is counted from entry, stentry, note, topic.
                2019-02-04 t.makita
     -->
    <xsl:function name="ahf:countUl" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmCount" as="xs:integer"/>
        
        <xsl:variable name="count" select="if ($prmElem[contains(@class, ' topic/ul ')]) then ($prmCount + 1) else $prmCount"/>
        <xsl:choose>
            <xsl:when test="$prmElem[ahf:seqContains(@class, (' topic/entry ',' topic/stentry '))]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="$prmElem[contains(@class, ' topic/note ')]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="$prmElem[contains(@class, ' topic/topic ')]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="exists($prmElem/parent::*)">
                <xsl:sequence select="ahf:countUl($prmElem/parent::*, $count)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$count"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:  sl template
     param:	    
     return:    fo:list-block
     note:      none
     -->
    <xsl:template match="*[contains(@class, ' topic/sl ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsSl'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/sl ')]">
        <xsl:variable name="doCompact" select="string(@compact) eq 'yes'" as="xs:boolean"/>
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmDoCompact" tunnel="yes" select="$doCompact"/>
            </xsl:apply-templates>
        </fo:list-block>
    </xsl:template>
    
    
    <xsl:template match="*[contains(@class, ' topic/sl ')]/*[contains(@class,' topic/sli ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsSlItem'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/sl ')]/*[contains(@class,' topic/sli ')]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:list-item>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:choose>
                <!-- Apply compact spacing -->
                <xsl:when test="$prmDoCompact">
                    <xsl:variable name="slCompactRatio" as="xs:double">
                        <xsl:call-template name="getVarValueWithLangAsDouble">
                            <xsl:with-param name="prmVarName" select="'Sl_Compact_Ratio'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <!--xsl:message select="'$slCompactRatio=',$slCompactRatio"/>
                    <xsl:message select="'$slCompactRatio castable as xs:double=',$slCompactRatio castable as xs:double"/-->
                    <xsl:variable name="slCompactAttrName" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'Sl_Compact_Attr'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="compactAttrVal" as="xs:string">
                        <xsl:call-template name="getAttributeValueWithLang">
                            <xsl:with-param name="prmAttrSetName" as="xs:string*">
                                <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                            </xsl:with-param>
                            <xsl:with-param name="prmAttrName" select="$slCompactAttrName"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:attribute name="{$slCompactAttrName}" 
                                   select="ahf:getPropertyRatio($compactAttrVal,$slCompactRatio)"/>
                </xsl:when>
            </xsl:choose>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:list-item-label end-indent="label-end()"> 
                <fo:block>
                    <fo:inline/>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <fo:block>
                    <xsl:apply-templates/>                    
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    
    <!-- 
     function:  dl template
     param:        
     return:    fo:block or fo:table
     note:		
     -->
    <xsl:function name="ahf:formatDlAsTable" as="xs:boolean">
        <xsl:param name="prmDlElem" as="element()"/>
        <xsl:sequence select="exists($prmDlElem/ancestor-or-self::*[contains(@class,' topic/dl ')][1]/*[contains(@class,' topic/dlhead ')])"/>
    </xsl:function>
    
    <xsl:template match="*[contains(@class, ' topic/dl ')][not(ahf:formatDlAsTable(.))]" mode="MODE_GET_STYLE" as="xs:string*">
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dl ')][ahf:formatDlAsTable(.)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDlTable'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dl ')][not(ahf:formatDlAsTable(.))]">
        <xsl:variable name="doCompact" select="string(@compact) eq 'yes'" as="xs:boolean"/>
        <fo:block>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]">
                <xsl:with-param name="prmDoCompact" tunnel="yes" select="$doCompact"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]">
                <xsl:with-param name="prmDoCompact" tunnel="yes" select="$doCompact"/>
            </xsl:apply-templates>
            <xsl:if test="not($pDisplayFnAtEndOfTopic)">
                <xsl:call-template name="makeFootNote">
                    <xsl:with-param name="prmElement"  select="."/>
                </xsl:call-template>
            </xsl:if>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dl ')][ahf:formatDlAsTable(.)]">
        <xsl:variable name="doCompact" select="string(@compact) eq 'yes'" as="xs:boolean"/>
        <fo:table>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]">
                <xsl:with-param name="prmDoCompact" tunnel="yes" select="$doCompact"/>
            </xsl:apply-templates>
            <fo:table-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsDlbody')"/>
                <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]">
                    <xsl:with-param name="prmDoCompact" tunnel="yes" select="$doCompact"/>
                </xsl:apply-templates>
            </fo:table-body>
        </fo:table>
        <xsl:if test="not($pDisplayFnAtEndOfTopic)">
            <xsl:call-template name="makeFootNote">
                <xsl:with-param name="prmElement"  select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlhead ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDlhead'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlhead ')]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
    
        <fo:table-header>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:table-row>
                <xsl:apply-templates>
                    <xsl:with-param name="prmDoCompact" select="$prmDoCompact"/>
                </xsl:apply-templates>
            </fo:table-row>
        </fo:table-header>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dthd ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDthd'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dthd ')]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:table-cell>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <fo:block>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:if test="$prmDoCompact">
                    <xsl:variable name="dlCompactRatio" as="xs:double">
                        <xsl:call-template name="getVarValueWithLangAsDouble">
                            <xsl:with-param name="prmVarName" select="'Dl_Compact_Ratio'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="dlCompactAttrName" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'Dl_Compact_Attr'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="dlCompactAttrVal" as="xs:string">
                        <xsl:call-template name="getAttributeValueWithLang">
                            <xsl:with-param name="prmAttrSetName" as="xs:string*">
                                <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                            </xsl:with-param>
                            <xsl:with-param name="prmAttrName" select="$dlCompactAttrName"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:attribute name="{$dlCompactAttrName}" 
                                   select="ahf:getPropertyRatio($dlCompactAttrVal,$dlCompactRatio)"/>
                </xsl:if>
                <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/ddhd ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDdhd'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/ddhd ')]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:table-cell>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <fo:block>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:if test="$prmDoCompact">
                    <xsl:variable name="dlCompactRatio" as="xs:double">
                        <xsl:call-template name="getVarValueWithLangAsDouble">
                            <xsl:with-param name="prmVarName" select="'Dl_Compact_Ratio'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="dlCompactAttrName" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'Dl_Compact_Attr'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="dlCompactAttrVal" as="xs:string">
                        <xsl:call-template name="getAttributeValueWithLang">
                            <xsl:with-param name="prmAttrSetName" as="xs:string*">
                                <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                            </xsl:with-param>
                            <xsl:with-param name="prmAttrName" select="$dlCompactAttrName"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:attribute name="{$dlCompactAttrName}" 
                                   select="ahf:getPropertyRatio($dlCompactAttrVal,$dlCompactRatio)"/>
                </xsl:if>
                <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlentry ')][not(ahf:formatDlAsTable(.))]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDlentryBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dlentry ')][ahf:formatDlAsTable(.)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDlentryTable'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlentry ')][not(ahf:formatDlAsTable(.))]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmDoCompact" tunnel="yes" select="$prmDoCompact"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlentry ')][ahf:formatDlAsTable(.)]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:table-row>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]">
                <xsl:with-param name="prmDoCompact" tunnel="yes" select="$prmDoCompact"/>
            </xsl:apply-templates>
            <fo:table-cell>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsDdTableCell'"/>
                </xsl:call-template>
                <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]">
                    <xsl:with-param name="prmDoCompact" tunnel="yes" select="$prmDoCompact"/>
                </xsl:apply-templates>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dt ')][not(ahf:formatDlAsTable(.))]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDtBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dt ')][ahf:formatDlAsTable(.)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDtTable'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dt ')][not(ahf:formatDlAsTable(.))]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:if test="$prmDoCompact">
                <xsl:variable name="dlCompactRatioBlockDt" as="xs:double">
                    <xsl:call-template name="getVarValueWithLangAsDouble">
                        <xsl:with-param name="prmVarName" select="'Dl_Compact_Ratio_Block_Dt'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="dlCompactAttrNameBlock" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Dl_Compact_Attr_Block'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="dlCompactAttrValBlock" as="xs:string">
                    <xsl:call-template name="getAttributeValueWithLang">
                        <xsl:with-param name="prmAttrSetName" as="xs:string*">
                            <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                        </xsl:with-param>
                        <xsl:with-param name="prmAttrName" select="$dlCompactAttrNameBlock"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="{$dlCompactAttrNameBlock}" 
                    select="ahf:getPropertyRatio($dlCompactAttrValBlock,$dlCompactRatioBlockDt)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dt ')][ahf:formatDlAsTable(.)]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:table-cell>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <fo:block>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:if test="$prmDoCompact">
                    <xsl:variable name="dlCompactRatio" as="xs:double">
                        <xsl:call-template name="getVarValueWithLangAsDouble">
                            <xsl:with-param name="prmVarName" select="'Dl_Compact_Ratio'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="dlCompactAttrName" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'Dl_Compact_Attr'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="dlCompactAttrVal" as="xs:string">
                        <xsl:call-template name="getAttributeValueWithLang">
                            <xsl:with-param name="prmAttrSetName" as="xs:string*">
                                <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                            </xsl:with-param>
                            <xsl:with-param name="prmAttrName" select="$dlCompactAttrName"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:attribute name="{$dlCompactAttrName}" 
                        select="ahf:getPropertyRatio($dlCompactAttrVal,$dlCompactRatio)"/>
                </xsl:if>
                <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dd ')][not(ahf:formatDlAsTable(.))]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDdBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dd ')][ahf:formatDlAsTable(.)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDdTable'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dd ')][not(ahf:formatDlAsTable(.))]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:if test="$prmDoCompact">
                <xsl:variable name="dlCompactRatioBlockDd" as="xs:double">
                    <xsl:call-template name="getVarValueWithLangAsDouble">
                        <xsl:with-param name="prmVarName" select="'Dl_Compact_Ratio_Block_Dd'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="dlCompactAttrNameBlock" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Dl_Compact_Attr_Block'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="dlCompactAttrValBlock" as="xs:string">
                    <xsl:call-template name="getAttributeValueWithLang">
                        <xsl:with-param name="prmAttrSetName" as="xs:string*">
                            <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                        </xsl:with-param>
                        <xsl:with-param name="prmAttrName" select="$dlCompactAttrNameBlock"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="{$dlCompactAttrNameBlock}" 
                               select="ahf:getPropertyRatio($dlCompactAttrValBlock,$dlCompactRatioBlockDd)"/>
            </xsl:if>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dd ')][ahf:formatDlAsTable(.)]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:if test="$prmDoCompact">
                <xsl:variable name="dlCompactRatio" as="xs:double">
                    <xsl:call-template name="getVarValueWithLangAsDouble">
                        <xsl:with-param name="prmVarName" select="'Dl_Compact_Ratio'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="dlCompactAttrName" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Dl_Compact_Attr'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="dlCompactAttrVal" as="xs:string">
                    <xsl:call-template name="getAttributeValueWithLang">
                        <xsl:with-param name="prmAttrSetName" as="xs:string*">
                            <xsl:apply-templates select="." mode="MODE_GET_STYLE"/>
                        </xsl:with-param>
                        <xsl:with-param name="prmAttrName" select="$dlCompactAttrName"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="{$dlCompactAttrName}" 
                    select="ahf:getPropertyRatio($dlCompactAttrVal,$dlCompactRatio)"/>
            </xsl:if>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>