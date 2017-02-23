<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Index common template
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:i18n_index_saxon9="java:jp.co.antenna.ah_i18n_index.IndexSortSaxon9"
 xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
 extension-element-prefixes="i18n_index_saxon9"
 exclude-result-prefixes="xs ahf i18n_index_saxon9 psmi"
>
    <!-- *************************************** 
            Index related
         ***************************************-->
    <xsl:variable name="cIndexSymbolLabel" select="ahf:getVarValue('Index_Symbol_Label')" as="xs:string"/>
    <xsl:variable name="cSeePrefixLevel1"  select="ahf:getVarValue('See_Prefix_Level1')" as="xs:string"/>
    <xsl:variable name="cSeeSuffixLevel1"  select="ahf:getVarValue('See_Suffix_Level1')" as="xs:string"/>
    <xsl:variable name="cSeePrefixLevel2"  select="ahf:getVarValue('See_Prefix_Level2')" as="xs:string"/>
    <xsl:variable name="cSeeSuffixLevel2"  select="ahf:getVarValue('See_Suffix_Level2')" as="xs:string"/>
    
    <!-- Index See Also prefix and suffix -->
    <xsl:variable name="cSeeAlsoPrefix" select="ahf:getVarValue('See_Also_Prefix')" as="xs:string"/>
    <xsl:variable name="cSeeAlsoSuffix" select="ahf:getVarValue('See_Also_Suffix')" as="xs:string"/>
    
    <!-- Index page citation -->
    <xsl:variable name="cIndexPageCitationListSeparator" select="ahf:getVarValue('Index_Page_Citation_List_Separator')" as="xs:string"/>
    <xsl:variable name="cIndexPageCitationRangeSeparator" select="ahf:getVarValue('Index_Page_Citation_Range_Separator')" as="xs:string"/>

    <!-- DEBUG Parameter: hidden -->
    <xsl:param name="PRM_DEBUG_INDEX_SORT_RESULT" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pDebugIndexSortResult" as="xs:boolean" select="$PRM_DEBUG_INDEX_SORT_RESULT eq $cYes"/>

    <!-- indexkey for @significance="preferred" (DocBook Only) -->
    <xsl:variable name="KEY_PREFERRED" select="'__KEY_PREFERRED'" as="xs:string"/>
    
    <!-- Sort key max length (When stylesheet does not use I18n Index Library) -->
    <xsl:variable name="cIndexSortKeyMaxLen" select="128" as="xs:integer"/>
    
    <!-- index-key separator -->
    <xsl:variable name="indexKeySep" select="':'"/>
    
    <!-- index id prefix -->
    <xsl:variable name="cIndexKeyPrefix" select="'__indexkey'"/>
    
    <!-- Moved from dita2fo_common.xsl -->
    <!-- 
     function:	Process indexterm in metadata
     param:		prmTopicRef, prmTopicContent
     return:	call indexterm template and make index-key or start FO object
     note:		This template should be called from the beginning of topic/title template.
                Changed to allow empty($prmTopicContent) 2011-07-25 t.makita
                The indexterm must be exist before (<<) the $lastTopicRef. 
                Otherwise it will be ignored by FO processor. 
                This template ignores if <indexterm> exists aftre the $lastTopicRef.
                2012-03-29 t.makita
     -->
    <xsl:template name="processIndextermInMetadata">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        
        <xsl:if test="$prmTopicRef &lt;&lt; $lastTopicRef or $prmTopicRef is $lastTopicRef">
            <!-- Make @index-key and start FO object for topicref/topicmeta/keywords/indexterm 
                 $prmTopicRef must be () because indexterm exists in topicref/topicmeta.
                 It does not exists in topic pointed by topicref.
             -->
            <xsl:choose>
                <xsl:when test="exists($prmTopicContent)">
                    <xsl:choose>
                        <xsl:when test="$prmTopicContent/ancestor::*[contains(@class,' topic/topic ')]"/>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$prmTopicRef/child::*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]">
                                <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                                <xsl:with-param name="prmMakeKeyAndStart" tunnel="yes" select="true()"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>            
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$prmTopicRef/child::*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                        <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                        <xsl:with-param name="prmMakeKeyAndStart" tunnel="yes" select="true()"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Make @index-key and start FO object for topic/prolog/metadata/keywords/indexterm -->
            <xsl:if test="exists($prmTopicContent)">
                <xsl:apply-templates select="$prmTopicContent/child::*[contains(@class, ' topic/prolog ')]/child::*[contains(@class, ' topic/metadata ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]">
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                    <xsl:with-param name="prmMakeKeyAndStart" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	Process indexterm in metadata
     param:		prmTopicRef, prmTopicContent
     return:	call indexterm template and make fo:index-range-end FO object
     note:		This template should be called from the end of topicref.
     -->
    <xsl:template name="processIndextermInMetadataEnd">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        
        <xsl:variable name="indextermRangeEnd" as="element()*">
            <!-- topicref/topicmeta/keywords/indexterm -->
            <xsl:apply-templates select="$prmTopicRef/child::*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]">
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                <xsl:with-param name="prmMakeEnd"  tunnel="yes" select="true()"/>
            </xsl:apply-templates>
            
            <!-- topic/prolog/metadata/keywords/indexterm -->
            <xsl:if test="exists($prmTopicContent)">
                <xsl:apply-templates select="$prmTopicContent/descendant-or-self::*[contains(@class,' topic/topic ')]/child::*[contains(@class, ' topic/prolog ')]/child::*[contains(@class, ' topic/metadata ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]">
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                    <xsl:with-param name="prmMakeEnd"  tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:if>
            
            <xsl:if test="exists($prmTopicContent)">
                <!-- Make fo:index-range-end FO object for topic/prolog/metadata/keywords/indexterm 
                     that has @start but has no corresponding @end indexterm
                 -->
                <xsl:apply-templates select="$prmTopicContent/descendant-or-self::*[contains(@class,' topic/topic ')]/child::*[contains(@class, ' topic/prolog ')]/child::*[contains(@class, ' topic/metadata ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]">
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                    <xsl:with-param name="prmMakeComplementEnd" tunnel="yes" select="true()"/>
                    <xsl:with-param name="prmRangeElem" tunnel="yes" select="$prmTopicRef"/><!-- Special! -->
                </xsl:apply-templates>
            </xsl:if>
            
            <!-- Make fo:index-range-end FO object for topicref/topicmeta/keywords/indexterm 
                 that has @start but has no corresponding @end indexterm
             -->
            <xsl:if test="$prmTopicRef is $lastTopicRef">
                <xsl:for-each select="$map/descendant::*[contains(@class,' map/topicref ')]">
                    <xsl:variable name="topicRef" select="."/>
                    <xsl:apply-templates select="$topicRef/child::*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                        <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                        <xsl:with-param name="prmMakeComplementEnd" tunnel="yes" select="true()"/>
                        <xsl:with-param name="prmRangeElem" tunnel="yes" select="$map"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        
        <xsl:if test="exists($indextermRangeEnd)">
            <fo:block-container>
                <xsl:copy-of select="$indextermRangeEnd"/>
            </fo:block-container>
        </xsl:if>
        
    </xsl:template>
    
    <!-- 
        function:	Complement indexterm[@end] in topic body portion
        param:		prmTopicRef, prmTopicContent
        return:	    call indexterm template and make fo:index-range-end FO object
        note:		This template should be called from the end of topic.
    -->
    <xsl:template name="processIndextermInTopicEnd">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()"/>
        
        <xsl:variable name="indextermRangeEnd" as="element()*">
            <!-- topic/title -->
            <xsl:apply-templates select="$prmTopicContent/child::*[contains(@class, ' topic/title ')]//*[contains(@class, ' topic/indexterm ')]">
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                <xsl:with-param name="prmMakeComplementEnd" tunnel="yes" select="true()"/>
                <xsl:with-param name="prmRangeElem" tunnel="yes" select="$prmTopicContent"/>
            </xsl:apply-templates>
            
            <!-- topic/shortdesc,abstract -->
            <xsl:apply-templates select="$prmTopicContent/child::*[contains(@class, ' topic/shortdesc ')]//*[contains(@class, ' topic/indexterm ')]">
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                <xsl:with-param name="prmMakeComplementEnd" tunnel="yes" select="true()"/>
                <xsl:with-param name="prmRangeElem" tunnel="yes" select="$prmTopicContent"/>
            </xsl:apply-templates>
            
            <xsl:apply-templates select="$prmTopicContent/child::*[contains(@class, ' topic/abstract ')]//*[contains(@class, ' topic/indexterm ')]">
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                <xsl:with-param name="prmMakeComplementEnd" tunnel="yes" select="true()"/>
                <xsl:with-param name="prmRangeElem" tunnel="yes" select="$prmTopicContent"/>
            </xsl:apply-templates>
            
            <!-- topic/body -->
            <xsl:apply-templates select="$prmTopicContent/child::*[contains(@class, ' topic/body ')]//*[contains(@class, ' topic/indexterm ')]">
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                <xsl:with-param name="prmMakeComplementEnd" tunnel="yes" select="true()"/>
                <xsl:with-param name="prmRangeElem" tunnel="yes" select="$prmTopicContent"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="exists($indextermRangeEnd)">
            <fo:block-container>
                <xsl:copy-of select="$indextermRangeEnd"/>    
            </fo:block-container>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function: General text mode templates for indexterm 
     param:    see below
     return:   text
     note:     Refer to text() template in dita2fo_common.xsl.
    -->
    <!-- indexterm -->
    <xsl:template match="*[contains(@class, ' topic/indexterm ')]" mode="TEXT_ONLY">
        <xsl:param name="prmGetIndextermText" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndextermKey"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeText"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeKey"   required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetSortAsText"    required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        
        <xsl:choose>
            <xsl:when test="$prmGetIndextermText">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndextermKey">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeText">
                <xsl:value-of select="', '"/>
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndexSeeText"  tunnel="yes" select="$prmGetIndexSeeText"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeKey">
                <xsl:value-of select="$indexKeySep"/>
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndexSeeKey"   tunnel="yes" select="$prmGetIndexSeeKey"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$prmGetSortAsText">
                <!-- indexterm is not allowed in index-sort-as -->
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    
    <!-- index-see,index-see-also,index-base -->
    <xsl:template match="*[contains(@class, ' indexing-d/index-see ')]
                        |*[contains(@class, ' indexing-d/index-see-also ')]
                        |*[contains(@class, ' topic/index-base ')]"
                  mode="TEXT_ONLY">
        <xsl:param name="prmGetIndextermText" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndextermKey"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeText"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeKey"   required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetSortAsText"    required="no" tunnel="yes" as="xs:boolean" select="false()"/>
    
        <xsl:choose>
            <xsl:when test="$prmGetIndextermText">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndextermKey">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeText">
                <!-- nested see, see-also does not allowed -->
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeKey">
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndexSeeKey"   tunnel="yes" select="$prmGetIndexSeeKey"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$prmGetSortAsText">
                <!-- index-see, index-see-also  is not allowed in index-sort-as -->
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    
    <!-- index-sort-as -->
    <xsl:template match="*[contains(@class, ' indexing-d/index-sort-as ')]"
                  mode="TEXT_ONLY"
                  priority="2">
        <xsl:param name="prmGetIndextermText" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndextermKey"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeText"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeKey"   required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetSortAsText"    required="no" tunnel="yes" as="xs:boolean" select="false()"/>
    
        <xsl:choose>
            <xsl:when test="$prmGetIndextermText">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndextermKey">
                <!-- Changed to get text as indexterm key to handle the following pattern:
                     <indexterm>&lt;data&gt;<index-sort-as>data</index-sort-as></indexterm>
                     <indexterm>&lt;data&gt;<index-sort-as>&lt;data&gt;</index-sort-as></indexterm>
                     2014-09-26 t.makita
                 -->
                <xsl:apply-templates mode="#current"/>
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeText">
                <!-- index-sort-as in not allowed in index-see, index-see-also -->
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeKey">
                <!-- index-sort-as in not allowed in index-see, index-see-also -->
            </xsl:when>
            <xsl:when test="$prmGetSortAsText">
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetSortAsText"    tunnel="yes" select="$prmGetSortAsText"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    
    
    <!-- 
     function: Get indexterm for index-key and FO object templates
     param:    - prmGetIndextermFO
                 Set true() when making indexterm formatting object (without id) for index page.
               - prmGetIndexSeeFO
                 Set true() when making index-see or index-see-also formatting object (without id) for index page.
               - prmMakeCover
                 Set true() when making formatting objects for cover page (mainly in dita2fo_global.xsl)
                 The indexterm in cover will be ignored.
               - prmGetContent
                 Set true() when upper template is invoked with mod="GET_CONTENT".
                 The corresponding template is code in dita2fo_common.xsl.
     return:   indexterm FO or nothing
     note:     none
    -->
    <!-- indexterm -->
    <xsl:template match="*[contains(@class, ' topic/indexterm ')]">
        <xsl:param name="prmGetIndextermFO" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeFO"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmMakeCover"      required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetContent" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        
        <xsl:choose>
            <xsl:when test="$prmGetIndextermFO">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeFO">
            	<!-- Somtimes indexterm exists as the child of index-see or index-see-also element -->
                <fo:inline>
                    <xsl:value-of select="', '"/>
                </fo:inline>
                <fo:inline>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmGetIndexSeeFO" tunnel="yes" select="$prmGetIndexSeeFO"/>
                    </xsl:apply-templates>
                </fo:inline>
            </xsl:when>
            <xsl:when test="$prmMakeCover">
                <!-- Ignore. Do not generate indexkey for the cover title items. -->
            </xsl:when>
            <xsl:when test="$prmGetContent">
                <!-- end! -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::*[contains(@class, ' topic/indexterm ')]">
                        <!-- IGNORE -->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Normal pattern: generate @index-key, fo:index-range-begin, fo:index-range-end -->
                        <!-- "MODE_PROCESS_INDEXTERM_MAIN" template is coded in dita2fo_indexterm.xsl -->
                        <xsl:apply-templates select="self::node()" mode="MODE_PROCESS_INDEXTERM_MAIN">
                            <xsl:with-param name="prmIndextermKey" select="''"/>
                            <xsl:with-param name="prmIndextermStart" select="''"/>
                            <xsl:with-param name="prmIndextermStartId" select="''"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template> 
    
    <!-- index-see,index-see-also,index-sort-as,index-base -->
    <xsl:template match="*[contains(@class, ' indexing-d/index-see ')]
                        |*[contains(@class, ' indexing-d/index-see-also ')]
                        |*[contains(@class, ' topic/index-base ')]">
        <xsl:param name="prmGetIndextermFO" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeFO"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
    
        <xsl:choose>
            <xsl:when test="$prmGetIndextermFO">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeFO">
                <fo:inline>
                    <xsl:call-template name="ahf:getUnivAtts"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmGetIndexSeeFO" tunnel="yes" select="$prmGetIndexSeeFO"/>
                    </xsl:apply-templates>
                </fo:inline>
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    
    <!-- index-sort-as -->
    <xsl:template match="*[contains(@class, ' indexing-d/index-sort-as ')]"
                  priority="2">
        <xsl:param name="prmGetIndextermFO" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeFO"  required="no" tunnel="yes" as="xs:boolean" select="false()"/>
    
        <xsl:choose>
            <xsl:when test="$prmGetIndextermFO">
                <!-- end! -->
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeFO">
                <!-- index-sort-as in not allowed in index-see, index-see-also -->
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    
    <!-- 
         Function: Generate indexterm key considering index-sort-as
         Param:    prmIndexterm
         Return:   xs:string 
         Note:     
      -->
    <xsl:template name="getIndextermKey" as="xs:string">
        <xsl:param name="prmIndexterm" as="element()" required="yes"/>
        <xsl:variable name="indextermKeyWoSortAs" as="xs:string">
            <xsl:variable name="tempIndextermKeyWoSortAs" as="xs:string*">
                <xsl:apply-templates select="$prmIndexterm/node() except $prmIndexterm/*[contains(@class,' indexing-d/index-sort-as ')]" mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndextermKey" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:sequence select="normalize-space(string-join($tempIndextermKeyWoSortAs,''))"/>
        </xsl:variable>
        <xsl:variable name="indextermKeySortAs" as="xs:string">
            <xsl:variable name="tempIndextermKeySortAs" as="xs:string*">
                <xsl:apply-templates select="$prmIndexterm/*[contains(@class,' indexing-d/index-sort-as ')]" mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndextermKey" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:sequence select="normalize-space(string-join($tempIndextermKeySortAs,''))"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="($indextermKeyWoSortAs ne $indextermKeySortAs) and string($indextermKeySortAs)">
                <xsl:sequence select="concat($indextermKeyWoSortAs,$indextermKeySortAs)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$indextermKeyWoSortAs"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    <!-- 
         Function: Make index page sequence
         Param:    none.
         Return:   fo:page-sequence 
         Note:     Current is booklists/indexlist
      -->
    <xsl:template name="genIndex">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="id" as="xs:string" select="string(ahf:getIdAtts($topicRef,$topicRef,true())[1])"/>
        
    	<!-- debug -->
    	<xsl:if test="$indextermOriginCount != $indextermSortedCount">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes" 
                 select="ahf:replace($stMes600,('%before','%after'),(string($indextermOriginCount),string($indextermSortedCount)))"/>
            </xsl:call-template>
    	</xsl:if>
    
        <xsl:if test="$pDebugIndexSortResult">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" select="$stMes601"/>
            </xsl:call-template>
            <!--xsl:result-document href="{concat($pOutputDirUrl,$pInputMapName,'_index_input.xml')}" encoding="UTF-8" byte-order-mark="no" indent="yes">
                <index-input>
                    <xsl:copy-of select="$indextermOrigin"/>
                </index-input>
            </xsl:result-document-->
            <xsl:result-document href="{concat($pOutputDirUrl,$pInputMapName,'_index_out.xml')}" encoding="UTF-8" byte-order-mark="no" indent="yes">
                <index-output>
                    <xsl:apply-templates select="$indextermSorted/*" mode="MODE_INDEX_DEBUG"/>
                </index-output>
            </xsl:result-document>
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" select="$stMes602"/>
            </xsl:call-template>
        </xsl:if>
    	
        <xsl:if test="$pOutputIndex and ($indextermSortedCount &gt; 0)">
    	    <psmi:page-sequence>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqIndex')"/>
                <fo:static-content flow-name="rgnIndexBeforeLeft">
		            <xsl:call-template name="indexBeforeLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBeforeRight">
                    <xsl:call-template name="indexBeforeRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterLeft">
		            <xsl:call-template name="indexAfterLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterRight">
                    <xsl:call-template name="indexAfterRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndRight">
                    <xsl:call-template name="indexEndRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndLeft">
                    <xsl:call-template name="indexEndLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBlankBody">
                    <xsl:call-template name="makeBlankBlock"/>
                </fo:static-content>
        		
        		<!-- INDEX main flow -->
        		<fo:flow flow-name="xsl-region-body">
                    <!-- Make "INDEX" title  -->
                    <fo:block>
                        <xsl:copy-of select="ahf:getAttributeSet('atsIndexHeader')"/>
                        <xsl:attribute name="id" select="$id"/>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline><xsl:copy-of select="$cIndexTitle"/></fo:inline>
                        </fo:marker>
                        <xsl:value-of select="$cIndexTitle"/>
                    </fo:block>
                    <!-- Make index content main -->
                    <xsl:call-template name="makeIndexContentControl"/>
        		</fo:flow>
        	</psmi:page-sequence>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*" mode="MODE_INDEX_DEBUG">
        <xsl:copy>
            <xsl:copy-of select="@* except (@xtrf|@xtrc|@id)"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
         Function: Make index page sequence for simple map
         Param:    none.
         Return:   fo:page-sequence 
         Note:     
      -->
    <xsl:template name="genMapIndex">
        
        <!-- debug -->
        <xsl:if test="$indextermOriginCount != $indextermSortedCount">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes" 
                    select="ahf:replace($stMes600,('%before','%after'),(string($indextermOriginCount),string($indextermSortedCount)))"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$pDebugIndexSortResult">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" select="$stMes601"/>
            </xsl:call-template>
            <!--xsl:result-document href="{concat($pOutputDirUrl,$pInputMapName,'_index_input.xml')}" encoding="UTF-8" byte-order-mark="no" indent="yes">
                <index-input>
                    <xsl:copy-of select="$indextermOrigin"/>
                </index-input>
            </xsl:result-document-->
            <xsl:result-document href="{concat($pOutputDirUrl,$pInputMapName,'_index_out.xml')}" encoding="UTF-8" byte-order-mark="no" indent="yes">
                <index-output>
                    <xsl:apply-templates select="$indextermSorted//*" mode="MODE_INDEX_DEBUG"/>
                </index-output>
            </xsl:result-document>
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" select="$stMes602"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$indextermSortedCount &gt; 0">
            <fo:page-sequence>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqIndex')"/>
                <fo:static-content flow-name="rgnIndexBeforeLeft">
                    <xsl:call-template name="indexBeforeRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBeforeRight">
                    <xsl:call-template name="indexBeforeRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterLeft">
                    <xsl:call-template name="indexAfterLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexAfterRight">
                    <xsl:call-template name="indexAfterRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndRight">
                    <xsl:call-template name="indexEndRight"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexEndLeft">
                    <xsl:call-template name="indexEndLeft"/>
                </fo:static-content>
                <fo:static-content flow-name="rgnIndexBlankBody">
                    <xsl:call-template name="makeBlankBlock"/>
                </fo:static-content>
                
                <!-- INDEX main flow -->
                <fo:flow flow-name="xsl-region-body">
                    <!-- Make "INDEX" title  -->
                    <fo:block>
                        <xsl:copy-of select="ahf:getAttributeSet('atsIndexHeader')"/>
                        <xsl:attribute name="id" select="$cIndexId"/>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline><xsl:copy-of select="$cIndexTitle"/></fo:inline>
                        </fo:marker>
                        <xsl:value-of select="$cIndexTitle"/>
                    </fo:block>
                    <!-- Make index content main -->
                    <xsl:call-template name="makeIndexContentControl"/>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <!-- 
     function: Making index content main control template. 
     param:    None
     return:   
     note:     
    -->
    <xsl:template name="makeIndexContentControl">
        <xsl:variable name="startId" select="string($indextermSorted/index-data[1]/@id)" as="xs:string"/>
    
        <xsl:variable name="startGroupLabel" select="ahf:getGroupLabel($startId)"/>
    
        <xsl:variable name="groupRange" select="ahf:getGroupRange($startId,$startGroupLabel)"/>
    
        <xsl:call-template name="makeIndexGroupControl">
            <xsl:with-param name="prmGroupLabel" select="$startGroupLabel"/>
            <xsl:with-param name="prmStartId" select="$startId"/>
            <xsl:with-param name="prmNextId" select="$groupRange[2]"/>
        </xsl:call-template>
    </xsl:template>
    
    <!--    function: Get group label
            param:    prmId
            return:   index-data/@group-label
            note:     group-label is generated by index sorting library
    -->
    <xsl:function name="ahf:getGroupLabel" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@group-label)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- function: Get range of the indexterm group
         param: prmCurrentId, prmGroupLabel
         return: [id(to)],[id(next)]
         note:Process starts from current indexterm element.
    -->
    <xsl:function name="ahf:getGroupRange" as="xs:string+">
        <xsl:param name="prmCurrentId" as="xs:string"/>
        <xsl:param name="prmGroupLabel" as="xs:string"/>
        
        <!--xsl:message>[get-group-range] $prmCurrentId:<xsl:value-of select="$prmCurrentId"/></xsl:message>
        <xsl:message>[get-group-range] $prmGroupLabel:<xsl:value-of select="$prmGroupLabel"/></xsl:message-->
        <xsl:variable name="nextId" select="ahf:getNextId($prmCurrentId)"/>
        
        <xsl:variable name="nextGroupLabel" select="ahf:getGroupLabel($nextId)"/>
    
        <!-- xsl:message>[get-group-range] $nextId:<xsl:value-of select="$nextId"/></xsl:message>
        <xsl:message>[get-group-range] $nextGroupLabel:<xsl:value-of select="$nextGroupLabel"/></xsl:message-->
        
        <xsl:choose>
            <xsl:when test="$prmGroupLabel != $nextGroupLabel">
                <!-- group key break -->
                <xsl:sequence select="$prmCurrentId"/>
                <xsl:sequence select="$nextId"/>
                <!-- xsl:message>[get-group-range] result=<xsl:value-of select="concat($prmCurrentId, '/', $nextId)"/></xsl:message -->
            </xsl:when>
            <xsl:otherwise>
                <!-- group key continues! Call recursively myself.-->
                <xsl:sequence select="ahf:getGroupRange($nextId,$prmGroupLabel)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- function: Index group control
         param:    prmGroupLabel, prmStartId, prmNextId
         return:
         note:
    -->
    <!-- group title returned from Java index sorting module -->
    <xsl:variable name="cGroupTitleOthers" select="'#NUMERIC'" as="xs:string"/>
    
    <xsl:template name="makeIndexGroupControl">
        <xsl:param name="prmGroupLabel" required="yes" as="xs:string"/>
        <xsl:param name="prmStartId"    required="yes" as="xs:string"/>
        <xsl:param name="prmNextId"     required="yes" as="xs:string"/>
    
        <!-- set group label -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsIndexGroupTitle')"/>
            <!-- CHANGE: If group-label == "#NUMERIC", replace it symbol label.
                 2009-03-27 t.makita
             -->
            <xsl:choose>
                <xsl:when test="$prmGroupLabel=$cGroupTitleOthers">
                    <!-- This occurs only when using I18n Index library. -->
                    <xsl:value-of select="$cIndexSymbolLabel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$prmGroupLabel"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    
        <xsl:variable name="currentIndexKey" select="ahf:getIndexKey($prmStartId)" as="xs:string"/>
        <xsl:variable name="currentSee" select="ahf:getSee($prmStartId)" as="xs:string"/>
        <xsl:variable name="currentSeeAlso" select="ahf:getSeeAlso($prmStartId)" as="xs:string"/>
        <xsl:variable name="indextermRange" select="ahf:getIndextermRange($prmGroupLabel,$prmStartId,$currentIndexKey,$currentSee,$currentSeeAlso)" as="xs:string+"/>
        <!--xsl:variable name="indextermRange" select="ahf:getIndextermRange($prmGroupLabel,$prmStartId,$currentIndexKey)" as="xs:string+"/-->
        
        <xsl:call-template name="makeIndexDetailLine">
            <xsl:with-param name="prmCurrentId" select="$prmStartId"/>
            <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
            <xsl:with-param name="prmCurrentIndexKey" select="$currentIndexKey"/>
            <xsl:with-param name="prmIndextermRange" select="$indextermRange"/>
        </xsl:call-template>
        
        <!-- next group processing -->
        <xsl:if test="string($prmNextId)">
            <xsl:variable name="startGroupLabel" select="ahf:getGroupLabel($prmNextId)"/>
            <xsl:variable name="groupRange" select="ahf:getGroupRange($prmNextId,$startGroupLabel)"/>
    
            <xsl:call-template name="makeIndexGroupControl">
                <xsl:with-param name="prmGroupLabel" select="$startGroupLabel"/>
                <xsl:with-param name="prmStartId" select="$prmNextId"/>
                <xsl:with-param name="prmNextId" select="$groupRange[2]"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    
    <!--    function: Get indexkey
            param: prmId
            return: index-data/@indexkey
            note:none
    -->
    <xsl:function name="ahf:getIndexKey" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@indexkey)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Get see
            param: prmId: id
            return: indexterm/@see
            note:none
    -->
    <xsl:function name="ahf:getSee" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@see)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Get see FO
            param: prmId: id
            return: indexterm/indexseefo
            note:none
    -->
    <xsl:function name="ahf:getSeeFO" as="node()*">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$indextermSorted/index-data[@id=$prmId]/indexseefo/child::node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!--    function: Get seealso
            param: prmId: id
            return: indexterm/@seealso
            note:none
    -->
    <xsl:function name="ahf:getSeeAlso" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@seealso)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Get seealso FO
            param: prmId: id
            return: indexterm/seealsofo
            note:none
    -->
    <xsl:function name="ahf:getSeeAlsoFO" as="node()*">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$indextermSorted/index-data[@id=$prmId]/indexseealsofo/child::node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!--    function: Get nestedindexterm
            param: prmId: id
            return: index-data/@nestedindexterm
            note:none
    -->
    <xsl:function name="ahf:getNestedIndexterm" as="xs:integer">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="0"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="xs:integer(string($indextermSorted/index-data[@id=$prmId]/@nestedindexterm))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Get range of the indexterm
            param:    See below
            return:   [id(to)],[id(next)]
            note:     Range key is indexkey/boolean(@see)/boolean(@seealso)
    -->
    <xsl:function name="ahf:getIndextermRange" as="xs:string+">
        <xsl:param name="prmGroupLabel" as="xs:string"/>
        <xsl:param name="prmCurrentId" as="xs:string"/>
        <xsl:param name="prmCurrentIndexKey" as="xs:string"/>
        <xsl:param name="prmCurrentSee" as="xs:string"/>
        <xsl:param name="prmCurrentSeeAlso" as="xs:string"/>
        
        <xsl:variable name="nextId" select="ahf:getNextId($prmCurrentId)"/>
        <xsl:variable name="nextGroupLabel" select="ahf:getGroupLabel($nextId)"/>
        <xsl:variable name="nextIndexKey" select="ahf:getIndexKey($nextId)"/>
        <xsl:variable name="nextSee" select="ahf:getSee($nextId)"/>
        <xsl:variable name="nextSeeAlso" select="ahf:getSeeAlso($nextId)"/>
        
        <xsl:choose>
            <xsl:when test="($prmGroupLabel != $nextGroupLabel) 
                         or ($prmCurrentIndexKey != $nextIndexKey)
                         or (boolean(string($prmCurrentSee)) != boolean(string($nextSee)))
                         or (boolean(string($prmCurrentSeeAlso)) != boolean(string($nextSeeAlso)))">
                <!-- group key,indexkey,see or seealso  breaks! -->
                <xsl:sequence select="$prmCurrentId"/>
                <xsl:sequence select="$nextId"/>
                <!-- xsl:message>[getIndextermRange] result=<xsl:value-of select="concat($prmCurrentId, '/', $nextId)"/></xsl:message -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- group-label/indexterm/see/seealso continues! -->
                    <xsl:when test="string($nextId)">
                        <xsl:sequence select="ahf:getIndextermRange($prmGroupLabel,$nextId,$prmCurrentIndexKey,$prmCurrentSee,$prmCurrentSeeAlso)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- end of element -->
                        <xsl:sequence select="$prmCurrentId"/>
                        <xsl:sequence select="''"/>
                        <!-- xsl:message>[getIndextermRange] result=<xsl:value-of select="concat($prmCurrentId, '/')"/></xsl:message -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!--    function: Make index detail line
            param:    See below.
            return:   Index detail line fo:block
            note: 
    -->
    <xsl:template name="makeIndexDetailLine">
        <xsl:param name="prmCurrentId" required="yes" as="xs:string"/>
        <xsl:param name="prmGroupLabel" required="yes" as="xs:string"/>
        <xsl:param name="prmCurrentIndexKey" required="yes" as="xs:string"/>
        <xsl:param name="prmIndextermRange" required="yes" as="xs:string+"/>
    
        <!--xsl:message>[makeIndexDetailLine] prmCurrentId=<xsl:value-of select="$prmCurrentId"/></xsl:message>
        <xsl:message>[makeIndexDetailLine] prmGroupLabel=<xsl:value-of select="$prmGroupLabel"/></xsl:message>
        <xsl:message>[makeIndexDetailLine] prmCurrentIndexKey=<xsl:value-of select="$prmCurrentIndexKey"/></xsl:message>
        <xsl:message>[makeIndexDetailLine] prmIndextermRange=<xsl:value-of select="$prmIndextermRange"/></xsl:message>
        <xsl:message>[makeIndexDetailLine] =============================================================</xsl:message-->
    
        <xsl:variable name="toId" select="$prmIndextermRange[1]"/>
        <xsl:variable name="nextId" select="$prmIndextermRange[2]"/>
        <xsl:variable name="nextGroupLabel" as="xs:string">
            <xsl:choose>
                <xsl:when test="not(string($nextId))">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ahf:getGroupLabel($nextId)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="currentLevel" select="ahf:getLevel($prmCurrentId)" as="xs:integer"/>
        <xsl:variable name="previousId"  select="string($indextermSorted/index-data[@id=$prmCurrentId]/preceding-sibling::index-data[1]/@id)" as="xs:string"/>
        <xsl:variable name="previousLevel" select="ahf:getLevel($previousId)"/>
        <xsl:variable name="startLevel" select="ahf:getIndextermStartLevel($prmCurrentId,$previousId,1,$currentLevel,$previousLevel)" as="xs:integer"/>
        <xsl:variable name="currentSee" select="ahf:getSee($prmCurrentId)" as="xs:string"/>
        <xsl:variable name="currentSeeAlso" select="ahf:getSeeAlso($prmCurrentId)" as="xs:string"/>
        <xsl:variable name="currentNestedIndexterm" select="ahf:getNestedIndexterm($prmCurrentId)" as="xs:integer"/>
        <xsl:variable name="countSignificancePreferred" select="ahf:countSignificance('preferred',$prmCurrentId,$toId,0)" as="xs:integer"/>
        <xsl:variable name="countSignificanceNormal" select="ahf:countSignificance('normal',$prmCurrentId,$toId,0)" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="not(string($currentSee)) and not(string($currentSeeAlso))">
                <!-- Only indexterm: Make detail line and fo:index-page-citation-list, fo:index-key-reference -->
                <xsl:call-template name="outIndextermDetailLine">
                    <xsl:with-param name="prmCurrentId"  select="$prmCurrentId"/>
                    <xsl:with-param name="prmStartLevel" select="$startLevel"/>
                    <xsl:with-param name="prmMaxLevel"   select="$currentLevel"/>
                    <xsl:with-param name="prmCurrentIndexKey"       select="$prmCurrentIndexKey"/>
                    <xsl:with-param name="prmSignificancePreferred" select="$countSignificancePreferred"/>
                    <xsl:with-param name="prmSignificanceNormal"    select="$countSignificanceNormal"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(string($currentSee)) and string($currentSeeAlso)">
                <!-- index-see-also: Make see also line only -->
                <xsl:variable name="currentSeeAlsoFO" select="ahf:getSeeAlsoFO($prmCurrentId)" as="node()*"/>
                <xsl:call-template name="outSeeAlsoDetailLine">
                    <xsl:with-param name="prmFromId"     select="$prmCurrentId"/>
                    <xsl:with-param name="prmToId"       select="$toId"/>
                    <xsl:with-param name="prmStartLevel" select="$startLevel"/>
                    <xsl:with-param name="prmCurrentSeeAlsoFO"   select="$currentSeeAlsoFO"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="string($currentSee) and not(string($currentSeeAlso))">
                <!-- index-see: Make see line only -->
                <xsl:variable name="currentSeeFO" select="ahf:getSeeFO($prmCurrentId)" as="node()*"/>
                <xsl:variable name="currentSee" select="ahf:getSee($prmCurrentId)" as="xs:string"/>
                <xsl:variable name="hasMultipleSee" select="ahf:checkMultipleSee($prmCurrentId,$toId,$currentSee)" as="xs:boolean"/>
                <xsl:call-template name="outSeeDetailLine">
                    <xsl:with-param name="prmFromId"  select="$prmCurrentId"/>
                    <xsl:with-param name="prmToId"  select="$toId"/>
                    <xsl:with-param name="prmStartLevel" select="$startLevel"/>
                    <xsl:with-param name="prmMaxLevel"   select="$currentLevel"/>
                    <xsl:with-param name="prmCurrentSeeFO" select="$currentSeeFO"/>
                    <xsl:with-param name="prmNestedIndexterm" select="$currentNestedIndexterm"/>
                    <xsl:with-param name="prmMultipleSee" select="$hasMultipleSee"/>
                    <xsl:with-param name="prmStart" select="true()"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- This pattern never occurs. -->
            </xsl:otherwise>
        </xsl:choose>
    
        <xsl:if test="string($nextId) and ($nextGroupLabel = $prmGroupLabel)">
            <!-- Move to next -->
            <xsl:variable name="nextIndexKey" select="ahf:getIndexKey($nextId)" as="xs:string"/>
            <xsl:variable name="nextSee" select="ahf:getSee($nextId)" as="xs:string"/>
            <xsl:variable name="nextSeeAlso" select="ahf:getSeeAlso($nextId)" as="xs:string"/>
            <xsl:variable name="indextermRange" select="ahf:getIndextermRange($prmGroupLabel,$nextId,$nextIndexKey,$nextSee,$nextSeeAlso)" as="xs:string+"/>
            <!--xsl:variable name="indextermRange" select="ahf:getIndextermRange($prmGroupLabel,$nextId,$nextIndexKey)" as="xs:string+"/-->
            
            <!-- call recursively myself -->
            <xsl:call-template name="makeIndexDetailLine">
                <xsl:with-param name="prmCurrentId" select="$nextId"/>
                <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
                <xsl:with-param name="prmCurrentIndexKey" select="$nextIndexKey"/>
                <xsl:with-param name="prmIndextermRange" select="$indextermRange"/>
            </xsl:call-template>
        </xsl:if>
    
    </xsl:template>
    
    
    <!--    function: Output indexterm detail line
            param:    See below
            return:   fo:block
            note:     none
    -->
    <xsl:template name="outIndextermDetailLine">
        <xsl:param name="prmCurrentId"  required="yes" as="xs:string"/>
        <xsl:param name="prmStartLevel" required="yes" as="xs:integer"/>
        <xsl:param name="prmMaxLevel"   required="yes" as="xs:integer"/>
        <xsl:param name="prmCurrentIndexKey"       required="yes" as="xs:string"/>
        <xsl:param name="prmSignificancePreferred" required="yes" as="xs:integer"/>
        <xsl:param name="prmSignificanceNormal"    required="yes" as="xs:integer"/>
        
        <!--xsl:message>[outIndextermDetailLine] prmCurrentId=<xsl:value-of select="$prmCurrentId"/></xsl:message>
        <xsl:message>[outIndextermDetailLine] prmStartLevel=<xsl:value-of select="$prmStartLevel"/></xsl:message>
        <xsl:message>[outIndextermDetailLine] prmMaxLevel=<xsl:value-of select="$prmMaxLevel"/></xsl:message>
        <xsl:message>[outIndextermDetailLine] prmCurrentIndexKey=<xsl:value-of select="$prmCurrentIndexKey"/></xsl:message-->
    
        <xsl:variable name="indextermFO"   select="ahf:getIndextermFO($prmCurrentId,$prmStartLevel)" as="node()*"/>
        
        <xsl:choose>
            <xsl:when test="$prmStartLevel &lt; $prmMaxLevel">
                <!-- This line is only indexterm title 
                     Set id for See, SeeAlso reference avoiding multiple id generation. (2011-10-04 t.makita)
                  -->
                <xsl:variable name="currentLevelIndexKey" select="ahf:getCurrentLevelIndexKey($prmCurrentId,$prmStartLevel)" as="xs:string"/>
                <xsl:variable name="currentLevelIndexkeyId" as="xs:string">
                	<xsl:choose>
                		<xsl:when test="string($currentLevelIndexKey)">
                			<xsl:sequence select="ahf:indexKeyToIdValue($currentLevelIndexKey)"/>
                		</xsl:when>
                		<xsl:otherwise>
                			<xsl:sequence select="''"/>
                		</xsl:otherwise>
                	</xsl:choose>
                </xsl:variable>
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineOnly',('%level'),(string($prmStartLevel)))"/>
                    <xsl:if test="string($currentLevelIndexkeyId)">
    	                <xsl:attribute name="id" select="$currentLevelIndexkeyId"/>
    	            </xsl:if>
                    <fo:inline><xsl:copy-of select="$indextermFO"/></fo:inline>
                </fo:block>
                <!-- Call recursively myself -->
                <xsl:call-template name="outIndextermDetailLine">
                    <xsl:with-param name="prmCurrentId"  select="$prmCurrentId"/>
                    <xsl:with-param name="prmStartLevel" select="$prmStartLevel + 1"/>
                    <xsl:with-param name="prmMaxLevel"   select="$prmMaxLevel"/>
                    <xsl:with-param name="prmCurrentIndexKey"       select="$prmCurrentIndexKey"/>
                    <xsl:with-param name="prmSignificancePreferred" select="$prmSignificancePreferred"/>
                    <xsl:with-param name="prmSignificanceNormal"    select="$prmSignificanceNormal"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$prmStartLevel = $prmMaxLevel">
                <!-- This line is title and fo:index-citation-list -->
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLine',('%level'),(string($prmStartLevel)))"/>
                    <fo:inline>
                        <xsl:if test="$pMakeSeeLink">
                            <xsl:attribute name="id">
                                <xsl:value-of select="ahf:indexKeyToIdValue($prmCurrentIndexKey)"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:copy-of select="$indextermFO"/>
                    </fo:inline>
                    <fo:leader>
                        <xsl:copy-of select="ahf:getAttributeSet('atsIndexLeader1')"/>
                    </fo:leader>
                    <fo:inline>
                        <xsl:copy-of select="ahf:getAttributeSet('atsIndex2ndLeaderInline')"/>
                        <fo:leader>
                            <xsl:copy-of select="ahf:getAttributeSet('atsIndexLeader2')"/>
                        </fo:leader>
                    </fo:inline>
                    <fo:index-page-citation-list>
                        <fo:index-page-citation-list-separator>
                            <xsl:value-of select="$cIndexPageCitationListSeparator"/>
                        </fo:index-page-citation-list-separator>
                        <fo:index-page-citation-range-separator>
                            <xsl:value-of select="$cIndexPageCitationRangeSeparator"/>
                        </fo:index-page-citation-range-separator>
                        <xsl:if test="$prmSignificancePreferred &gt; 0">
                            <xsl:variable name="preferredIndexKey">
                                <xsl:value-of select="$prmCurrentIndexKey"/>
                                <xsl:value-of select="$indexKeySep"/>
                                <xsl:value-of select="$KEY_PREFERRED"/>
                            </xsl:variable>
                            <fo:index-key-reference ref-index-key="{$preferredIndexKey}"> 
                                <xsl:copy-of select="ahf:getAttributeSet('atsIndexKeyReference atsIndexPreferred')"/>
                            </fo:index-key-reference>
                        </xsl:if>
                        <xsl:if test="$prmSignificanceNormal &gt; 0">
                            <fo:index-key-reference ref-index-key="{$prmCurrentIndexKey}">
                                <xsl:copy-of select="ahf:getAttributeSet('atsIndexKeyReference')"/>
                            </fo:index-key-reference>
                        </xsl:if>
                    </fo:index-page-citation-list>
                </fo:block>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!--    function: Output index-see-also detail line
            param:    See below
            return:   fo:block
            note:     none
    -->
    <xsl:template name="outSeeAlsoDetailLine">
        <xsl:param name="prmFromId"     required="yes" as="xs:string"/>
        <xsl:param name="prmToId"       required="yes" as="xs:string"/>
        <xsl:param name="prmStartLevel" required="yes" as="xs:integer"/>
        <xsl:param name="prmCurrentSeeAlsoFO" required="yes" as="node()*"/>
        
        <!--xsl:message>[outSeeAlsoDetailLine] prmFromId=<xsl:value-of select="$prmFromId"/></xsl:message>
        <xsl:message>[outSeeAlsoDetailLine] prmToId=<xsl:value-of select="$prmToId"/></xsl:message>
        <xsl:message>[outSeeAlsoDetailLine] prmStartLevel=<xsl:value-of select="$prmStartLevel"/></xsl:message>
        <xsl:message>[outSeeAlsoDetailLine] prmCurrentSeeAlso=<xsl:value-of select="$prmCurrentSeeAlso"/></xsl:message>
        <xsl:message>[outSeeAlsoDetailLine] =============================================================</xsl:message-->
        <!-- SeeAlso key -->
        <xsl:variable name="seeAlsoKey" select="ahf:getSeeAlsoKey($prmFromId)" as="xs:string"/>
        <xsl:variable name="seeAlsoId"  select="ahf:indexKeyToIdValue($seeAlsoKey)" as="xs:string"/>
        <xsl:variable name="seeAlso"    select="ahf:getSeeAlso($prmFromId)" as="xs:string"/>
        
        <!-- next SeeAlso key -->
        <xsl:variable name="nextSeeAlso" as="xs:string">
            <xsl:choose>
                <xsl:when test="$prmFromId = $prmToId">
                    <xsl:sequence select="''"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)"/>
                    <xsl:choose>
                        <xsl:when test="string($nextId)">
                            <xsl:sequence select="ahf:getSeeAlso($nextId)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$seeAlso != $nextSeeAlso">
            <!-- Output see also block -->
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($prmStartLevel)))"/>
                <fo:inline>
                    <xsl:copy-of select="ahf:getAttributeSet('atsSeeAlsoPrefix')"/>
                    <xsl:value-of select="$cSeeAlsoPrefix"/>
                </fo:inline>
                <xsl:choose>
                    <xsl:when test="$pMakeSeeLink">
                        <fo:basic-link internal-destination="{$seeAlsoId}">
                            <xsl:copy-of select="$prmCurrentSeeAlsoFO"/>
                        </fo:basic-link>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:inline>
                            <xsl:copy-of select="$prmCurrentSeeAlsoFO"/>
                        </fo:inline>
                    </xsl:otherwise>
                </xsl:choose>
                <fo:inline>
                    <xsl:copy-of select="ahf:getAttributeSet('atsSeeAlsoSuffix')"/>
                    <xsl:value-of select="$cSeeAlsoSuffix"/>
                </fo:inline>
            </fo:block>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="$prmFromId = $prmToId">
                <!-- Normal end -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)"/>
                <xsl:if test="string($nextId)">
                    <xsl:variable name="nextSeeAlsoFO" select="ahf:getSeeAlsoFO($nextId)" as="node()*"/>
                    <!-- Move to next index-see-also -->
                    <xsl:call-template name="outSeeAlsoDetailLine">
                        <xsl:with-param name="prmFromId"       select="$nextId"/>
                        <xsl:with-param name="prmToId"         select="$prmToId"/>
                        <xsl:with-param name="prmStartLevel"   select="$prmStartLevel"/>
                        <xsl:with-param name="prmCurrentSeeAlsoFO" select="$nextSeeAlsoFO"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--    function: Output index-see detail line
            param:    See below
            return:   fo:block
            note:     none
    -->
    <xsl:template name="outSeeDetailLine">
        <xsl:param name="prmFromId"  required="yes" as="xs:string"/>
        <xsl:param name="prmToId"   required="yes" as="xs:string"/>
        <xsl:param name="prmStartLevel" required="yes" as="xs:integer"/>
        <xsl:param name="prmMaxLevel"   required="yes" as="xs:integer"/>
        <xsl:param name="prmCurrentSeeFO" required="yes" as="node()*"/>
        <xsl:param name="prmNestedIndexterm" required="yes" as="xs:integer"/>
        <xsl:param name="prmMultipleSee" required="yes" as="xs:boolean"/>
        <xsl:param name="prmStart" required="yes" as="xs:boolean"/>
        
        <xsl:variable name="indextermFO"   select="ahf:getIndextermFO($prmFromId,$prmStartLevel)" as="node()*"/>
        
        <!--xsl:message>==============================================</xsl:message>
        <xsl:message>$prmFromId=<xsl:value-of select="$prmFromId"/></xsl:message>
        <xsl:message>$prmToId=<xsl:value-of select="$prmToId"/></xsl:message>
        <xsl:message>$prmStartLevel=<xsl:value-of select="$prmStartLevel"/></xsl:message>
        <xsl:message>$prmMaxLevel=<xsl:value-of select="$prmMaxLevel"/></xsl:message>
        <xsl:message>$prmNestedIndexterm=<xsl:value-of select="$prmNestedIndexterm"/></xsl:message>
        <xsl:message>$prmMultipleSee=<xsl:value-of select="$prmMultipleSee"/></xsl:message>
        <xsl:message>$prmStart=<xsl:value-of select="$prmStart"/></xsl:message-->
        
        <xsl:choose>
            <xsl:when test="$prmStartLevel &lt; $prmMaxLevel">
                <!-- This line is only indexterm title -->
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLine',('%level'),(string($prmStartLevel)))"/>
                    <fo:inline><xsl:copy-of select="$indextermFO"/></fo:inline>
                </fo:block>
                <!-- Call recursively myself -->
                <xsl:call-template name="outSeeDetailLine">
                    <xsl:with-param name="prmFromId"  select="$prmFromId"/>
                    <xsl:with-param name="prmToId"  select="$prmToId"/>
                    <xsl:with-param name="prmStartLevel" select="$prmStartLevel + 1"/>
                    <xsl:with-param name="prmMaxLevel"   select="$prmMaxLevel"/>
                    <xsl:with-param name="prmCurrentSeeFO" select="$prmCurrentSeeFO"/>
                    <xsl:with-param name="prmNestedIndexterm" select="$prmNestedIndexterm"/>
                    <xsl:with-param name="prmMultipleSee" select="$prmMultipleSee"/>
                    <xsl:with-param name="prmStart" select="$prmStart"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$prmStartLevel = $prmMaxLevel">
                <!-- This line is title and index-see text -->
                <xsl:variable name="seeKey" select="ahf:getSeeKey($prmFromId)" as="xs:string"/>
                <xsl:variable name="seeKeyId" select="ahf:indexKeyToIdValue($seeKey)" as="xs:string"/>
                <xsl:variable name="see" select="ahf:getSee($prmFromId)" as="xs:string"/>
    
                <!-- next See -->
                <xsl:variable name="nextSee" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$prmFromId = $prmToId">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)"/>
                            <xsl:choose>
                                <xsl:when test="string($nextId)">
                                    <xsl:sequence select="ahf:getSee($nextId)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="$see=$nextSee">
                        <!-- skip output -->
                    </xsl:when>
                    <xsl:when test="($prmNestedIndexterm = 0) and (not($prmMultipleSee))">
                        <!-- indexterm + see -->
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($prmStartLevel)))"/>
                            <fo:inline>
                                <xsl:copy-of select="$indextermFO"/>
                            </fo:inline>
                            <fo:inline>
                                <xsl:copy-of select="ahf:getAttributeSet('atsSeePrefix')"/>
                                <xsl:value-of select="$cSeePrefixLevel1"/>
                            </fo:inline>
                            <xsl:choose>
                                <xsl:when test="$pMakeSeeLink">
                                    <fo:basic-link internal-destination="{$seeKeyId}">
                                        <xsl:copy-of select="$prmCurrentSeeFO"/>
                                    </fo:basic-link>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:inline>
                                        <xsl:value-of select="$prmCurrentSeeFO"/>
                                    </fo:inline>
                                </xsl:otherwise>
                            </xsl:choose>
                            <fo:inline>
                                <xsl:copy-of select="ahf:getAttributeSet('atsSeeSuffix')"/>
                                <xsl:value-of select="$cSeeSuffixLevel1"/>
                            </fo:inline>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$prmStart">
                            <!-- indexterm -->
                            <fo:block>
                                <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineOnly',('%level'),(string($prmStartLevel)))"/>
                                <fo:inline>
                                    <xsl:value-of select="$indextermFO"/>
                                </fo:inline>
                            </fo:block>
                        </xsl:if>
                        <!-- See entry as indented-->
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($prmStartLevel + 1)))"/>
                            <fo:inline>
                                <xsl:copy-of select="ahf:getAttributeSet('atsSeePrefix')"/>
                                <xsl:value-of select="$cSeePrefixLevel2"/>
                            </fo:inline>
                            <xsl:choose>
                                <xsl:when test="$pMakeSeeLink">
                                    <fo:basic-link internal-destination="{$seeKeyId}">
                                        <xsl:copy-of select="$prmCurrentSeeFO"/>
                                    </fo:basic-link>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:inline>
                                        <xsl:copy-of select="$prmCurrentSeeFO"/>
                                    </fo:inline>
                                </xsl:otherwise>
                            </xsl:choose>
                            <fo:inline>
                                <xsl:copy-of select="ahf:getAttributeSet('atsSeeSuffix')"/>
                                <xsl:value-of select="$cSeeSuffixLevel2"/>
                            </fo:inline>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$prmFromId = $prmToId">
                        <!-- Normal end -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)"/>
                        <xsl:if test="string($nextId)">
                            <xsl:variable name="nextSeeFO" select="ahf:getSeeFO($nextId)" as="node()*"/>
                            <xsl:variable name="nextNestedIndexterm" select="ahf:getNestedIndexterm($nextId)" as="xs:integer"/>
                            <!-- Move to next index-see -->
                            <xsl:call-template name="outSeeDetailLine">
                                <xsl:with-param name="prmFromId"       select="$nextId"/>
                                <xsl:with-param name="prmToId"         select="$prmToId"/>
                                <xsl:with-param name="prmStartLevel"   select="$prmMaxLevel"/>
                                <xsl:with-param name="prmMaxLevel"     select="$prmMaxLevel"/>
                                <xsl:with-param name="prmCurrentSeeFO" select="$nextSeeFO"/>
                                <xsl:with-param name="prmNestedIndexterm" select="$nextNestedIndexterm"/>
                                <xsl:with-param name="prmMultipleSee"  select="$prmMultipleSee"/>
                                <xsl:with-param name="prmStart"        select="if (($see=$nextSee) and $prmStart) then true() else false()"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Test! This case is only for independent see line-->
                <xsl:variable name="seeKey" select="ahf:getSeeKey($prmFromId)" as="xs:string"/>
                <xsl:variable name="seeKeyId" select="ahf:indexKeyToIdValue($seeKey)" as="xs:string"/>
                <xsl:variable name="see" select="ahf:getSee($prmFromId)" as="xs:string"/>
                
                <!-- next See -->
                <xsl:variable name="nextSee" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$prmFromId = $prmToId">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)"/>
                            <xsl:choose>
                                <xsl:when test="string($nextId)">
                                    <xsl:sequence select="ahf:getSee($nextId)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="$see=$nextSee">
                        <!-- skip output -->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- See entry as indented-->
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSetReplacing('atsIndexLineSee',('%level'),(string($prmStartLevel)))"/>
                            <fo:inline>
                                <xsl:copy-of select="ahf:getAttributeSet('atsSeePrefix')"/>
                                <xsl:copy-of select="$cSeePrefixLevel2"/>
                            </fo:inline>
                            <xsl:choose>
                                <xsl:when test="$pMakeSeeLink">
                                    <fo:basic-link internal-destination="{$seeKeyId}">
                                        <xsl:copy-of select="$prmCurrentSeeFO"/>
                                    </fo:basic-link>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:inline>
                                        <xsl:copy-of select="$prmCurrentSeeFO"/>
                                    </fo:inline>
                                </xsl:otherwise>
                            </xsl:choose>
                            <fo:inline>
                                <xsl:copy-of select="ahf:getAttributeSet('atsSeeSuffix')"/>
                                <xsl:copy-of select="$cSeeSuffixLevel2"/>
                            </fo:inline>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$prmFromId = $prmToId">
                        <!-- Normal end -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)"/>
                        <xsl:if test="string($nextId)">
                            <xsl:variable name="nextSeeFO" select="ahf:getSeeFO($nextId)" as="node()*"/>
                            <xsl:variable name="nextNestedIndexterm" select="ahf:getNestedIndexterm($nextId)" as="xs:integer"/>
                            <!-- Move to next index-see -->
                            <xsl:call-template name="outSeeDetailLine">
                                <xsl:with-param name="prmFromId"       select="$nextId"/>
                                <xsl:with-param name="prmToId"         select="$prmToId"/>
                                <xsl:with-param name="prmStartLevel"   select="$prmStartLevel"/>
                                <xsl:with-param name="prmMaxLevel"     select="$prmMaxLevel"/>
                                <xsl:with-param name="prmCurrentSeeFO" select="$nextSeeFO"/>
                                <xsl:with-param name="prmNestedIndexterm" select="$nextNestedIndexterm"/>
                                <xsl:with-param name="prmMultipleSee"  select="$prmMultipleSee"/>
                                <xsl:with-param name="prmStart"        select="if (($see=$nextSee) and $prmStart) then true() else false()"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--    function: Check this group has different multiple see 
            param:    prmFromId, prmToId, prmPrevSee
            return:   xs:boolean
            note:     none
    -->
    <xsl:function name="ahf:checkMultipleSee" as="xs:boolean">
        <xsl:param name="prmFromId" as="xs:string"/>
        <xsl:param name="prmToId"   as="xs:string"/>
        <xsl:param name="prmPrevSee" as="xs:string"/>
        
        <xsl:variable name="prevSee" select="$prmPrevSee" as="xs:string"/>
        <xsl:variable name="currSee" select="ahf:getSee($prmFromId)" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$prevSee=$currSee">
                <xsl:choose>
                    <xsl:when test="$prmFromId=$prmToId">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)" as="xs:string"/>
                        <xsl:choose>
                            <xsl:when test="not(string($nextId))">
                                <xsl:sequence select="false()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="ahf:checkMultipleSee($nextId,$prmToId,$prevSee)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!--    function: Get indexterm text
            param:    prmId, prmLevel
            return:   indexterm text
            note:     currently not used (for debug only)
    -->
    <xsl:function name="ahf:getIndextermText" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:param name="prmLevel" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/child::indexterm[$prmLevel]/child::text())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Get indexterm FO
            param:    prmId, prmLevel
            return:   indexterm FO
            note:     none
    -->
    <xsl:function name="ahf:getIndextermFO" as="node()*">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:param name="prmLevel" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$indextermSorted/index-data[@id=$prmId]/child::indexterm[$prmLevel]/indextermfo/child::node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    
    <!--    function: Count significance attribute value
            param:    prmCountVal, prmFromId, prmToId, prmCount
            return:   Count of attribute where value = $prmCountVal
            note:     none
    -->
    <xsl:function name="ahf:countSignificance" as="xs:integer">
        <xsl:param name="prmCountVal" as="xs:string"/>
        <xsl:param name="prmFromId"   as="xs:string"/>
        <xsl:param name="prmToId"     as="xs:string"/>
        <xsl:param name="prmCount"    as="xs:integer"/>
        
        <xsl:variable name="countVal" as="xs:integer">
            <xsl:choose>
                <xsl:when test="not(string($prmFromId))">
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$indextermSorted/index-data[@id=$prmFromId]/@significance=$prmCountVal">
                            <xsl:sequence select="1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)" as="xs:string"/>
    
        <xsl:choose>
            <xsl:when test="$prmFromId=$prmToId">
                <xsl:sequence select="$prmCount+$countVal"/>
            </xsl:when>
            <xsl:when test="not(string($nextId))">
                <xsl:sequence select="$prmCount+$countVal"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="ahf:countSignificance($prmCountVal,$nextId,$prmToId,$prmCount+$countVal)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Dispaly error see to console
            param:    prmFromId, prmToId
            return:   none
            note:     deprecated
    -->
    <!--xsl:template name="displayErrorSee">
        <xsl:param name="prmFromId" required="yes" as="xs:string"/>
        <xsl:param name="prmToId"   required="yes" as="xs:string"/>
        <xsl:param name="prmSee"    required="yes" as="xs:string"/>
        <xsl:param name="prmIndexKey" required="yes" as="xs:string"/>
        <xsl:param name="prmXtrf"   required="yes" as="xs:string"/>
        
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" 
             select="ahf:replace($stMes605,('%key','%see','%file'),($prmIndexKey,$prmSee,$prmXtrf))"/>
        </xsl:call-template>
    
        <xsl:variable name="nextId" select="ahf:getNextId($prmFromId)" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$prmFromId=$prmToId">
            </xsl:when>
            <xsl:when test="string($nextId)">
                <xsl:variable name="nextSee" select="ahf:getSee($nextId)" as="xs:string"/>
                <xsl:variable name="nextXtrf" select="ahf:getXtrf($nextId)" as="xs:string"/>
                <xsl:call-template name="displayErrorSee">
                    <xsl:with-param name="prmFromId" select="$nextId"/>
                    <xsl:with-param name="prmToId"   select="$prmToId"/>
                    <xsl:with-param name="prmSee"    select="$nextSee"/>
                    <xsl:with-param name="prmIndexKey" select="$prmIndexKey"/>
                    <xsl:with-param name="prmXtrf"   select="$nextXtrf"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template-->
    
    <!--    function: Get level
            param: prmId
            return: index-data/@level
            note:none
    -->
    <xsl:function name="ahf:getLevel" as="xs:integer">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(string($prmId))">
                <xsl:sequence select="0"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="xs:integer(string($indextermSorted/index-data[@id=$prmId]/@level))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Get indexterm print start level
            param:    prmId, prmPreviousId, prmLevel, prmLevelMax, prmPreviousLevelMax
            return:   level
            note:     Return the indexterm level that should be printed comparing previous indexterm data.
    -->
    <xsl:function name="ahf:getIndextermStartLevel" as="xs:integer">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:param name="prmPreviousId" as="xs:string"/>
        <xsl:param name="prmLevel" as="xs:integer"/>
        <xsl:param name="prmLevelMax" as="xs:integer"/>
        <xsl:param name="prmPreviousLevelMax" as="xs:integer"/>
        
        <xsl:variable name="previousIndexterm" as="xs:string">
            <xsl:choose>
                <xsl:when test="not(string($prmPreviousId))">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$prmLevel &gt; $prmPreviousLevelMax">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string($indextermSorted/index-data[@id=$prmPreviousId]/indexterm[$prmLevel]/child::text())"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="currentIndexterm" select="string($indextermSorted/index-data[@id=$prmId]/indexterm[$prmLevel]/child::text())" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$previousIndexterm = $currentIndexterm">
                <!-- This level does not differ -->
                <xsl:choose>
                    <xsl:when test="($prmLevel+1) &gt; $prmLevelMax">
                        <!-- This case will occuer when current is index-see-also. -->
                        <xsl:sequence select="$prmLevel+1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="ahf:getIndextermStartLevel($prmId,$prmPreviousId,$prmLevel+1,$prmLevelMax,$prmPreviousLevelMax)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$prmLevel"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--    function: Get next id
            param: prmCurrentId
            return: next id
            note:none
    -->
    <xsl:function name="ahf:getNextId" as="xs:string">
        <xsl:param name="prmCurrentId" as="xs:string"/>
        <xsl:sequence select="string($indextermSorted/index-data[@id=$prmCurrentId]/following-sibling::index-data[1]/@id)"/>
    </xsl:function>
    
    <!--    function: Get @xtrf
            param: prmId
            return: @xtrf
            note:none
    -->
    <xsl:function name="ahf:getXtrf" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@xtrf)"/>
    </xsl:function>
    
    <!--    function: Get @xtrc
            param: prmId
            return: @xtrc
            note:none
    -->
    <xsl:function name="ahf:getXtrc" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@xtrc)"/>
    </xsl:function>
    
    <!--    function: Get @seekey
            param: prmId
            return: @seekey
            note:none
    -->
    <xsl:function name="ahf:getSeeKey" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@seekey)"/>
    </xsl:function>
    
    <!--    function: Get currentlevel indexkey
            param: prmId, prmLevel
            return: index-data[@id=$prmId]/indexterm[$prmLevel]/@indexkey
            note:none
    -->
    <xsl:function name="ahf:getCurrentLevelIndexKey" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:param name="prmLevel" as="xs:integer"/>
        <xsl:variable name="indexkey" select="string($indextermSorted/index-data[@id=$prmId]/indexterm[$prmLevel]/@indexkey)" as="xs:string"/>
        <xsl:choose>
        	<xsl:when test="$indextermSorted/index-data[@id=$prmId]/preceding-sibling::index-data/indexterm[$prmLevel][string(@indexkey) eq $indexkey ]">
        		<xsl:sequence select="''"/>
        	</xsl:when>
        	<xsl:otherwise>
        		<xsl:sequence select="$indexkey"/>
        	</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!--    function: Get @seealsokey
            param: prmId
            return: @seealsokey
            note:none
    -->
    <xsl:function name="ahf:getSeeAlsoKey" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:sequence select="string($indextermSorted/index-data[@id=$prmId]/@seealsokey)"/>
    </xsl:function>
    
    <!--    function: Get id value from index key
            param: prmKey
            return: id string
            note:none
    -->
    <xsl:function name="ahf:indexKeyToIdValue" as="xs:string">
        <xsl:param name="prmKey" as ="xs:string"/>
        <!--xsl:sequence select="concat('_',replace($prmKey,'[:\C]','_'))"/-->
        <xsl:sequence select="concat($cIndexKeyPrefix,'_',ahf:stringToHexString($prmKey))"/>
    </xsl:function>


</xsl:stylesheet>
