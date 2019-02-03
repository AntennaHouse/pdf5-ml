<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: List related elements stylesheet
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
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
     function:	ol template
     param:	    
     return:	Numbered list (fo:list-block)
     note:		Call "processOl" for overriding from other plug-ins.
                2015-08-25 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ol ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsOl'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ol ')]">
        <xsl:call-template name="processOl"/>
    </xsl:template>
    
    <xsl:template name="processOl">
        <!-- Prefix of ol -->
        <xsl:variable name="olNumberFormat" as="xs:string+">
            <xsl:call-template name="getVarValueWithLangAsStringSequence">
                <xsl:with-param name="prmVarName" select="'Ol_Number_Formats'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="numberFormat" select="ahf:getOlNumberFormat(.,$olNumberFormat)" as="xs:string"/>
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmNumberFormat" tunnel="yes" select="$numberFormat"/>
            </xsl:apply-templates>
        </fo:list-block>
        <xsl:if test="not($pDisplayFnAtEndOfTopic)">
            <xsl:call-template name="makeFootNote">
                <xsl:with-param name="prmElement"  select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	ol/li template
     param:	    
     return:	Numbered list (fo:list-item)
     note:		Add consideration for stepsection.
                (2011-10-24 t.makita)
                Call "processOlLi" for overriding from other plug-ins.
                2015-08-25 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ol ')]/*[contains(@class,' topic/li ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsOlItem'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/ol ')]/*[contains(@class,' topic/li ')]">
        <xsl:param name="prmNumberFormat" required="yes" tunnel="yes" as="xs:string"/>

        <xsl:call-template name="processOlLi">
            <xsl:with-param name="prmNumberFormat" select="$prmNumberFormat"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="processOlLi">
        <xsl:param name="prmNumberFormat" required="yes" as="xs:string"/>

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
    </xsl:template>
    
    <!-- 
     function:	Get ol number format
     param:		prmOl, prmOlNumberFormat
     return:	Number format string
     note:		Count ol in entry/note independently.
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
     function:	ul template
     param:	    
     return:	Unordered list (fo:list-block)
     note:		Call "processUl" for overriding from other plug-ins.
                2015-08-25 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ul ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsUl'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ul ')]">
        <xsl:call-template name="processUl"/>
    </xsl:template>
    
    <xsl:template name="processUl">
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:list-block>
        <xsl:if test="not($pDisplayFnAtEndOfTopic)">
            <xsl:call-template name="makeFootNote">
                <xsl:with-param name="prmElement"  select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	ul/li template
     param:	    
     return:	Unordered list (fo:list-item)
     note:		Call "processUlLi" for overriding from other plug-ins.
                2015-08-25 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/ul ')]/*[contains(@class,' topic/li ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsUlItem'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ul ')]/*[contains(@class,' topic/li ')]">
        <xsl:call-template name="processUlLi"/>
    </xsl:template>
    
    <xsl:template name="processUlLi">
        <xsl:variable name="ulLabelChars" as="xs:string+">
            <xsl:call-template name="getVarValueWithLangAsStringSequence">
                <xsl:with-param name="prmVarName" select="'Ul_Label_Chars'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ulLabelCharCount" as="xs:integer" select="count($ulLabelChars)"/>
        <xsl:variable name="ulIndex" as="xs:integer">
            <xsl:variable name="ulNestLevel" as="xs:integer" select="ahf:countUl(.,0)"/>
            <xsl:variable name="ulTempIndex" as="xs:integer" select="$ulNestLevel mod $ulLabelCharCount"/>
            <xsl:sequence select="if ($ulTempIndex eq 0) then $ulLabelCharCount else $ulTempIndex"/>
        </xsl:variable>
        <xsl:variable name="ulLabelChar" as="xs:string" select="$ulLabelChars[$ulIndex]"/>
        <fo:list-item>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:list-item-label end-indent="label-end()"> 
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsUlLabel'"/>
                    </xsl:call-template>
                    <xsl:value-of select="$ulLabelChar"/>
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
    </xsl:template>

    <!-- 
     function:	Count ul nesting level
     param:	    prmElem, prmCount
     return:	xs:integer
     note:		A nesting level is counted from entry, stentry, note, topic.
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
     function:	sl template
     param:	    
     return:	fo:list-block
     note:		none
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
     function:	dl template
     param:	    
     return:	fo:block or fo:table
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/dl ')][$pFormatDlAsBlock]" mode="MODE_GET_STYLE" as="xs:string*">
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dl ')][not($pFormatDlAsBlock)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDl'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dl ')][$pFormatDlAsBlock]">
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

    <xsl:template match="*[contains(@class, ' topic/dl ')][not($pFormatDlAsBlock)]">
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
    
    <xsl:template match="*[contains(@class, ' topic/ddhd ')][$pFormatDlAsBlock]" mode="MODE_GET_STYLE" as="xs:string*">
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/ddhd ')][not($pFormatDlAsBlock)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDlhead'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dlhead ')][$pFormatDlAsBlock]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" 
                select="ahf:replace($stMes055,('%file'),(string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlhead ')][not($pFormatDlAsBlock)]">
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
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/ddhd ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDdhd'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/ddhd ')]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:table-cell>
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
        </fo:table-cell>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlentry ')][$pFormatDlAsBlock]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDlentryBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dlentry ')][not($pFormatDlAsBlock)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDlentry'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlentry ')][$pFormatDlAsBlock]">
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

    <xsl:template match="*[contains(@class, ' topic/dlentry ')][not($pFormatDlAsBlock)]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:table-row>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmDoCompact" tunnel="yes" select="$prmDoCompact"/>
            </xsl:apply-templates>
        </fo:table-row>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dt ')][$pFormatDlAsBlock]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDtBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dt ')][not($pFormatDlAsBlock)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDt'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dt ')][$pFormatDlAsBlock]">
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

    <xsl:template match="*[contains(@class, ' topic/dt ')][not($pFormatDlAsBlock)]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <xsl:variable name="hasDlhead" as="xs:boolean" select="exists(ancestor::*[contains(@class,' topic/dl ')]/child::*[contains(@class,' topic/dlhead ')])"/>
        <fo:table-cell>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
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
                <xsl:if test="$hasDlhead">
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsDtHasDlhead'"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dd ')][$pFormatDlAsBlock]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDdBlock'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dd ')][not($pFormatDlAsBlock)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsDd'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dd ')][$pFormatDlAsBlock]">
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

    <xsl:template match="*[contains(@class, ' topic/dd ')][not($pFormatDlAsBlock)]">
        <xsl:param name="prmDoCompact" required="yes" tunnel="yes" as="xs:boolean"/>
        
        <fo:table-cell>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
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
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>

</xsl:stylesheet>