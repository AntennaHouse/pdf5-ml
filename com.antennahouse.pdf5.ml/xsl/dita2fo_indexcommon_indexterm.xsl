<?xml version="1.0" encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Index common template
    Copyright © 2009-2021 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
     xmlns:fo="http://www.w3.org/1999/XSL/Format" 
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
     xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
     exclude-result-prefixes="xs axf ahf"
    >
    <!-- *************************************** 
            Index related
         ***************************************-->
    <!-- index-key separator
         Changed from ":" or "&#x0A;" to get accurate token from key variables that uses this $indexKeySep
         "&#x0A;" is useless, it is replaced to "&#x20;" when applying normalize-space() function.
         2021-05-28 t.makita
         Chnaged from U+FFFD to U+F8FF (last character of BMP PUA) because the former is used in zh-CN pinyin input as non-Hanzi character.
         2021-07-24 t.makita
     -->
    <!--xsl:variable name="indexKeySep" select="'&#xFFFD;'"/-->
    <xsl:variable name="indexKeySep" select="'&#xF8FF;'"/>
    
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
                <xsl:apply-templates select="$prmIndexterm/*[contains(@class,$CLASS_INDEX_SORTAS)]" mode="TEXT_ONLY">
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
         Function: Generate indexterm key without considering index-sort-as
         Param:    prmIndexterm
         Return:   xs:string 
         Note:     Used for making key for index-see, index-see-also
                   2019-11-03 t.makita
      -->
    <xsl:template name="getIndextermKeyForSee" as="xs:string">
        <xsl:param name="prmIndexterm" as="element()" required="yes"/>
        <xsl:variable name="indextermKeyWoSortAs" as="xs:string">
            <xsl:variable name="tempIndextermKeyWoSortAs" as="xs:string*">
                <xsl:apply-templates select="$prmIndexterm/node() except $prmIndexterm/*[contains(@class,$CLASS_INDEX_SORTAS)]" mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndextermKey" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:sequence select="normalize-space(string-join($tempIndextermKeyWoSortAs,''))"/>
        </xsl:variable>
        <xsl:sequence select="$indextermKeyWoSortAs"/>
    </xsl:template>
    
</xsl:stylesheet>
