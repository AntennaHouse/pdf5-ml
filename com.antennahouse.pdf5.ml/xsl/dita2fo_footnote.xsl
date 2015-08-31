<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Make footnote as postnote
Copyright © 2009-2012 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!--  makePostNote, makePostNoteSub, processPostnote are used when $PRM_DIPLAY_FN_AT_END_OF_TOPIC="yes"-->
    <!-- 
     function:  postnote control
     param:     prmTopicRef, prmTopicContent
     return:    footnote lists
     note:      $prmTopicContent is any element.
                This template outputs post-note that is descendant of $prmTopicContent. 2011-07-28 t.makita
     -->
    <xsl:template name="makePostNote">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        <xsl:variable name="noteCount" select="if (exists($prmTopicContent)) then count($prmTopicContent/descendant::*[contains(@class,' topic/fn ')][not(contains(@class,' pr-d/synnote '))]) else 0"/>
        <xsl:if test="$noteCount gt 0">
            <xsl:call-template name="makePostNoteSub">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:  Make postnote sub
     param:     prmTopicRef, prmTopicContent
     return:    fo:block (postnote fo objects)
     note:      Select language specific title for postnote.
                2014-04-08 t.makita
     -->
    <xsl:template name="makePostNoteSub">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()"/>
        
        <!-- Make related-link title block -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteTitleBeforeBlock')"/>
            <fo:leader>
                <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteLeader1')"/>
            </fo:leader>
            <fo:inline>
                <xsl:value-of select="ahf:getVarValue('Postnote_Title')"/>
                <xsl:call-template name="getVarValueWithLangAsText">
                    <xsl:with-param name="prmVarName" select="'atsPostnoteInline'"/>
                    <xsl:with-param name="prmElem" select="$prmTopicContent"/>
                </xsl:call-template>
            </fo:inline>
            <fo:leader>
                <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteLeader2')"/>
            </fo:leader>
        </fo:block>
        
        <!-- process postnote -->
        <xsl:call-template name="processPostnote">
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
        </xsl:call-template>
        
        <!-- Make postnote end block -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteTitleAfterBlock')"/>
            <fo:leader>
                <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteLeader3')"/>
            </fo:leader>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:  Process postnote
     param:     prmTopicRef, prmTopicContent
     return:    postnote list blocks
     note:      Apply language specific style only for the style named 'atsPostnoteLi'.
                2015-04-08 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/fn ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsPostnoteLi'"/>
    </xsl:template>    

    <xsl:template name="processPostnote">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()"/>
        
        <fo:list-block>
            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteListBlock')"/>
            <xsl:for-each select="$prmTopicContent/descendant::*[contains(@class,' topic/fn ')]">
                <xsl:variable name="fn" select="."/>
                <fo:list-item>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmElem" select="$fn"/>
                    </xsl:call-template>
                    <xsl:if test="position() eq 1">
                        <xsl:attribute name="space-before" select="'0mm'"/>
                    </xsl:if>
                    <fo:list-item-label end-indent="label-end()"> 
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteLabel')"/>
                            <xsl:value-of select="ahf:getFootnotePrefix($fn,$prmTopicRef)"/>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="body-start()">
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteBody')"/>
                            <xsl:copy-of select="ahf:getUnivAtts($fn,$prmTopicRef,true())"/>
                            <xsl:if test="empty($fn/@id)">
                                <xsl:attribute name="id" select="ahf:generateId($fn,$prmTopicRef)"/>
                            </xsl:if>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty($fn)"/>
                            <xsl:apply-templates>
                                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNeedId"   select="true()"/>
                            </xsl:apply-templates>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </xsl:for-each>
        </fo:list-block>
    </xsl:template>
    
    
    <!-- 
     function:  Footnote control
     param:     prmElement
     return:    footnote list
     note:      $prmElement is any element.
                This template outputs footnote that is descendant of $prmElement. 2012-04-03 t.makita
     -->
    <xsl:template name="makeFootNote">
        <xsl:param name="prmElement"  required="yes" as="element()"/>
        
        <xsl:variable name="upperElements"  select="$prmElement/ancestor::*[contains(@class, ' topic/table ')] | 
                                                    $prmElement/ancestor::*[contains(@class, ' topic/simpletable ')] | 
                                                    $prmElement/ancestor::*[contains(@class, ' topic/ul ')] | 
                                                    $prmElement/ancestor::*[contains(@class, ' topic/ol ')] |
                                                    $prmElement/ancestor::*[contains(@class, ' topic/dl ')] |
                                                    $prmElement/ancestor::*[contains(@class, ' glossentry/glossdef ')]"
                                                    as="element()*"/>
        <xsl:variable name="fnCount" select="count($prmElement/descendant::*[contains(@class,' topic/fn ')][not(contains(@class,' pr-d/synnote '))])"/>
        <xsl:if test="empty($upperElements) and $fnCount gt 0">
            <xsl:call-template name="makeFootNoteSub">
                <xsl:with-param name="prmElement" select="$prmElement"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
        
    <!-- 
     function:  Make footnote sub
     param:     prmTopicRef, prmElement
     return:    fo:block (footnote fo objects)
     note:        
     -->
    <xsl:template name="makeFootNoteSub">
        <xsl:param name="prmElement"  required="yes" as="element()"/>
        
        <!-- Make related-link title block -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsFootNoteBeforeBlock')"/>
            <fo:inline>&#xA0;</fo:inline>
        </fo:block>
        
        <!-- process postnote -->
        <xsl:call-template name="processFootNote">
            <xsl:with-param name="prmElement"  select="$prmElement"/>
        </xsl:call-template>
        
        <!-- Make postnote end block -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsFootNoteAfterBlock')"/>
            <fo:inline>&#xA0;</fo:inline>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:  Process footnote
     param:     prmTopicRef, prmTopicContent
     return:    footnote list blocks
     note:      Apply language specific style only for the style named 'atsPostnoteLi'.
                2015-04-08 t.makita
     -->
    <xsl:template name="processFootNote">
        <xsl:param name="prmElement" required="yes" as="element()"/>
        
        <fo:list-block>
            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteListBlock')"/>
            <xsl:for-each select="$prmElement/descendant::*[contains(@class,' topic/fn ')]">
                <xsl:variable name="fn" select="."/>
                <fo:list-item>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmElem" select="$fn"/>
                    </xsl:call-template>
                    <xsl:if test="position() eq 1">
                        <xsl:attribute name="space-before" select="'0mm'"/>
                    </xsl:if>
                    <fo:list-item-label end-indent="label-end()"> 
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteLabel')"/>
                            <xsl:value-of select="ahf:getFootnotePrefix2($fn,$prmElement)"/>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="body-start()">
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPostnoteBody')"/>
                            <xsl:call-template name="ahf:getUnivAtts">
                                <xsl:with-param name="prmElement" select="$fn"/>
                            </xsl:call-template>
                            <xsl:if test="empty($fn/@id)">
                                <xsl:attribute name="id">
                                    <xsl:call-template name="ahf:generateId">
                                        <xsl:with-param name="prmElement" select="$fn"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:copy-of select="ahf:getFoStyleAndProperty($fn)"/>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </xsl:for-each>
        </fo:list-block>
    </xsl:template>
    
</xsl:stylesheet>
