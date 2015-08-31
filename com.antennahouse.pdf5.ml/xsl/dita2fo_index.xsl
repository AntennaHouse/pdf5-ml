<?xml version="1.0" encoding="UTF-8" ?>
<!--
*******************************************************************
DITA to XSL-FO Stylesheet
Module: Index generation template (Does not use I18n Index Library)
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
*******************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
 exclude-result-prefixes="xs ahf"
>

    <!--
        =========================================================
        This module specific global variables (Treat as constant)
        =========================================================
      -->
    <!--xsl:variable name="paddingSpace" select="string-join(for $i in 1 to $cIndexSortKeyMaxLen return ' ','')" as="xs:string"/-->
    <xsl:variable name="cIndexElementName" as="xs:string" select="'index-data'"/>
    <xsl:variable name="cSortKeyElementName" as="xs:string" select="'key'"/>
    <!--
        ======================================================
        Indexterm nodeset
        ======================================================
      -->
    <!-- Make original indexterm nodeset
         Added dummy tunnel parameter. (2011-09-27 t.makita)
     -->
    <xsl:variable name="indextermOrigin">
        <xsl:apply-templates select="$map//*[contains(@class, ' map/topicref ')]
                                            [not(ancestor::*[contains(@class,' map/reltable ')])]"
                             mode="MAKE_INDEX_ORIGIN">
        </xsl:apply-templates>
    </xsl:variable>
    
    <!-- Indexterm nodeset sorted result -->
    <xsl:variable name="indextermSorted">
    	<xsl:choose>
    	<xsl:when test="count($indextermOrigin/*) gt 0">
            <xsl:variable name="tempSortResult">
                <xsl:call-template name="indexSort">
                    <xsl:with-param name="prmIndexterm" select="$indextermOrigin"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:document>
                <xsl:for-each select="$tempSortResult/*">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="id" select="ahf:generateHistoryId(.)"/>
                        <xsl:copy-of select="*"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
    	</xsl:when>
    	    <xsl:otherwise>
    	        <xsl:document/>
    	    </xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>
    
    <!-- counts -->
    <xsl:variable name="indextermOriginCount" select="count($indextermOrigin/index-data)" as="xs:integer"/>
    <xsl:variable name="indextermSortedCount" select="count($indextermSorted/index-data)" as="xs:integer"/>
    
    <!--
        ======================================================
        Templates for making original indexterm nodeset
        ======================================================
      -->
    
    <!-- map/topicref -->
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="MAKE_INDEX_ORIGIN">
        <xsl:variable name="topicRef" select="."/>
    
        <!-- topicref/topicmeta -->
        <xsl:apply-templates select="$topicRef/*[contains(@class,$CLASS_TOPICMETA)]
                                              /*[contains(@class,$CLASS_KEYWORDS)]
                                              /*[contains(@class,$CLASS_INDEXTERM)]"
                             mode="MAKE_INDEX_ORIGIN">
            <xsl:with-param name="prmTopicRef"      tunnel="yes" select="$topicRef"/>
            <xsl:with-param name="prmFoIndexKey"    select="''"/>
            <xsl:with-param name="prmIndexSortKey"  select="()"/>
            <xsl:with-param name="prmLevel"         select="0"/>
            <xsl:with-param name="prmIndexLabel"    select="''"/>
            <xsl:with-param name="prmIndextermElem" select="()"/>
        </xsl:apply-templates>
    
        <xsl:variable name="linkTopic" select="ahf:getTopicFromTopicRef($topicRef)" as="element()?"/>
        
        <!-- process topic -->
        <xsl:if test="exists($linkTopic)">
            <xsl:apply-templates select="$linkTopic" mode="MAKE_INDEX_ORIGIN">
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="."/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    
    <!-- Linked topic/topic -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="MAKE_INDEX_ORIGIN">
        
        <xsl:apply-templates select="descendant::*[contains(@class,$CLASS_INDEXTERM)]
                                                  [not(ancestor::*[contains(@class,$CLASS_INDEXTERM)])]"
                             mode="MAKE_INDEX_ORIGIN">
            <xsl:with-param name="prmFoIndexKey"    select="''"/>
            <xsl:with-param name="prmIndexSortKey"  select="()"/>
            <xsl:with-param name="prmLevel"         select="0"/>
            <xsl:with-param name="prmIndexLabel"    select="''"/>
            <xsl:with-param name="prmIndextermElem" select="()"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- 
     function: indexterm template
     param:    See below
     return:   index-data nodeset
     note:     none
    -->
    <xsl:template match="*[contains(@class, ' topic/indexterm ')]" mode="MAKE_INDEX_ORIGIN">
        <xsl:param name="prmFoIndexKey"    required="yes" as="xs:string"/>
        <xsl:param name="prmIndexSortKey"  required="yes" as="xs:string*"/>
        <xsl:param name="prmLevel"         required="yes" as="xs:integer"/>
        <xsl:param name="prmIndexLabel"    required="yes" as="xs:string"/>
        <xsl:param name="prmIndextermElem" required="yes" as="element()*"/>
    
        <!-- Level of this indexterm -->
        <xsl:variable name="currentLevel" select="$prmLevel+1" as="xs:integer"/>
    
        <!-- Text of this indexterm -->
        <xsl:variable name="indextermText" as="xs:string">
            <xsl:variable name="tempIndextermText" as="xs:string*">
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndextermText" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space(string-join($tempIndextermText,''))"/>
        </xsl:variable>
    
        <!-- Key of this indexterm
             Add the following case:
             <indexterm>data<index-sort-as>data</index-sort-as></indexterm>
             2014-09-27 t.makita
          -->
        <xsl:variable name="indextermKey" as="xs:string">
            <xsl:call-template name="getIndextermKey">
                <xsl:with-param name="prmIndexterm" select="."/>
            </xsl:call-template>
        </xsl:variable>
    
        <!-- FO of this indexterm -->
        <xsl:variable name="indextermFO" as="node()*">
            <fo:inline>
                <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
                <xsl:apply-templates>
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                    <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                    <xsl:with-param name="prmGetIndextermFO" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </fo:inline>
        </xsl:variable>
    
        <!-- Current sortas text -->
        <xsl:variable name="indexSortasText" as="xs:string">
            <xsl:variable name="tempIndexSortasText" as="xs:string*">
                <xsl:apply-templates mode="TEXT_ONLY" 
                                     select="child::*[contains(@class,$CLASS_INDEX_SORTAS)]">
                    <xsl:with-param name="prmGetSortAsText"    tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space(string-join($tempIndexSortasText,''))"/>
        </xsl:variable>
    
        <!-- Index label -->
        <xsl:variable name="currentIndexLabel" as="xs:string">
            <xsl:choose>
                <xsl:when test="$currentLevel=1">
                    <xsl:call-template name="getIndexLabel">
                        <xsl:with-param name="prmIndexContent">
                            <xsl:choose>
                                <xsl:when test="string($indexSortasText)">
                                    <xsl:value-of select="$indexSortasText"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$indextermText"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$prmIndexLabel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <!-- Current FO index key -->
        <xsl:variable name="currentFoIndexKey" as="xs:string">
            <xsl:choose>
                <xsl:when test="not(string($prmFoIndexKey))">
                    <xsl:value-of select="$indextermKey"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($prmFoIndexKey,$indexKeySep,$indextermKey)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Current sortkey -->
        <xsl:variable name="currentIndexSortKey" as="xs:string*">
            <xsl:variable name="tempSortKey" as="xs:string">
                <xsl:choose>
                    <xsl:when test="not(string($indexSortasText))">
                        <xsl:value-of select="$indextermText"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$indexSortasText"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!--xsl:variable name="currentSortKeyFixLen1" as="xs:string">
                <xsl:value-of select="substring(concat($tempSortKey,$paddingSpace),1,$cIndexSortKeyMaxLen)"/>
            </xsl:variable>
            <xsl:variable name="currentSortKeyFixLen2" as="xs:string">
                <xsl:value-of select="substring(concat($indextermText,$paddingSpace),1,$cIndexSortKeyMaxLen)"/>
            </xsl:variable>
            <xsl:value-of select="concat($prmIndexSortKey,$currentSortKeyFixLen1,$currentSortKeyFixLen2)"/-->
            <xsl:sequence select="($prmIndexSortKey,$tempSortKey)"/>
        </xsl:variable>
        
        <!-- Current indexterm element 
             Added this level @indexkey. (2011-10-04 t.makita)
         -->
        <xsl:variable name="currentIndextermElement" as="element()*">
            <xsl:copy-of select="$prmIndextermElem"/>
            <xsl:element name="indexterm">
                <xsl:if test="string($indexSortasText)">
                    <xsl:attribute name="sortas">
                        <xsl:value-of select="$indexSortasText"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="indexkey" select="$currentFoIndexKey"/>
                <xsl:element name="indextermfo">
                    <xsl:copy-of select="$indextermFO"/>
                </xsl:element>
                <xsl:value-of select="$indextermText"/>
            </xsl:element>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="@end">
                <!-- Ignore indexterm that has @end attribute -->
            </xsl:when>
                <xsl:when test="not(string($indextermText))">
                    <!-- Ignore indexterm that has no text -->
                </xsl:when>
            <xsl:when test="(child::*[contains(@class, $CLASS_INDEX_SEE)]) 
                        and (child::*[contains(@class, $CLASS_INDEX_SEEALSO)])
                        and not(child::*[contains(@class, $CLASS_INDEXTERM)])">
                <!-- Ignore index-see. Adopt index-see-also only. -->
                <!-- generate element for sorting -->
                <xsl:variable name="seq" as="xs:string">
                    <xsl:call-template name="genIndexSeq">
                        <xsl:with-param name="prmIndexterm" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="{$cIndexElementName}">
                    <!--xsl:attribute name="id">
                        <xsl:value-of select="ahf:generateId(.,$prmTopicRef)"/>
                    </xsl:attribute-->
                    <xsl:attribute name="group-label">
                        <xsl:value-of select="$currentIndexLabel"/>
                    </xsl:attribute>
                    <xsl:attribute name="indexkey">
                        <xsl:value-of select="$currentFoIndexKey"/>
                    </xsl:attribute>
                    <xsl:attribute name="level">
                        <xsl:value-of select="$currentLevel"/>
                    </xsl:attribute>
                    <xsl:attribute name="nestedindexterm">
                        <xsl:value-of select="'0'"/>
                    </xsl:attribute>
                    <xsl:attribute name="significance">
                        <xsl:value-of select="'normal'"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@xtrf"/>
                    <!-- Sortkey -->
                    <xsl:for-each select="$currentIndexSortKey">
                        <xsl:element name="{$cSortKeyElementName}">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:element name="{$cSortKeyElementName}">
                        <xsl:value-of select="concat(' ',$seq)"/>
                    </xsl:element>
                    <!--xsl:value-of select="$currentIndexSortKey"/>
                    <xsl:value-of select="' '"/--><!-- Sort indexterm only key first 2009/07/17 t.makita -->
                    <!--xsl:value-of select="$seq"/-->
                    <!-- indexterm data -->
                    <xsl:copy-of select="$currentIndextermElement"/>
                </xsl:element>
                <!-- Navigate to child index-see-also -->
                <xsl:apply-templates select="child::*[contains(@class, $CLASS_INDEX_SEEALSO)]"
                                     mode="MAKE_INDEX_ORIGIN">
                    <xsl:with-param name="prmFoIndexKey"    select="$currentFoIndexKey"/>
                    <xsl:with-param name="prmIndexSortKey"  select="$currentIndexSortKey"/>
                    <xsl:with-param name="prmLevel"         select="$currentLevel"/>
                    <xsl:with-param name="prmIndexLabel"    select="$currentIndexLabel"/>
                    <xsl:with-param name="prmIndextermElem" select="$currentIndextermElement"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="child::*[contains(@class, $CLASS_INDEXTERM)]
                         or child::*[contains(@class, $CLASS_INDEX_SEE)]">
                <!-- Navigate to child indexterm,index-see -->
                <xsl:apply-templates select="child::*[contains(@class, $CLASS_INDEXTERM)]
                                            |child::*[contains(@class, $CLASS_INDEX_SEE)]"
                                     mode="MAKE_INDEX_ORIGIN">
                    <xsl:with-param name="prmFoIndexKey"    select="$currentFoIndexKey"/>
                    <xsl:with-param name="prmIndexSortKey"  select="$currentIndexSortKey"/>
                    <xsl:with-param name="prmLevel"         select="$currentLevel"/>
                    <xsl:with-param name="prmIndexLabel"    select="$currentIndexLabel"/>
                    <xsl:with-param name="prmIndextermElem" select="$currentIndextermElement"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="child::*[contains(@class, $CLASS_INDEX_SEEALSO)]">
                <!-- As index-see-also must generate page reference and see also indication both,
                     here generates two index-data elements.
                 -->
                <!-- generate element for sorting -->
                <xsl:variable name="seq" as="xs:string">
                    <xsl:call-template name="genIndexSeq">
                        <xsl:with-param name="prmIndexterm" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="{$cIndexElementName}">
                    <!--xsl:attribute name="id">
                        <xsl:value-of select="ahf:generateId(.,$prmTopicRef)"/>
                    </xsl:attribute-->
                    <xsl:attribute name="group-label">
                        <xsl:value-of select="$currentIndexLabel"/>
                    </xsl:attribute>
                    <xsl:attribute name="indexkey">
                        <xsl:value-of select="$currentFoIndexKey"/>
                    </xsl:attribute>
                    <xsl:attribute name="level">
                        <xsl:value-of select="$currentLevel"/>
                    </xsl:attribute>
                    <xsl:attribute name="nestedindexterm">
                        <xsl:value-of select="'0'"/>
                    </xsl:attribute>
                    <xsl:attribute name="significance">
                        <xsl:value-of select="'normal'"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@xtrf"/>
                    <!-- Sortkey -->
                    <xsl:for-each select="$currentIndexSortKey">
                        <xsl:element name="{$cSortKeyElementName}">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:element name="{$cSortKeyElementName}">
                        <xsl:value-of select="concat(' ',$seq)"/>
                    </xsl:element>
                    <!--xsl:value-of select="$currentIndexSortKey"/>
                    <xsl:value-of select="' '"/--><!-- Sort indexterm only key first 2009/07/17 t.makita -->
                    <!--xsl:value-of select="$seq"/-->
                    <!-- indexterm data -->
                    <xsl:copy-of select="$currentIndextermElement"/>
                </xsl:element>
                <!-- Navigate to child index-see-also -->
                <xsl:apply-templates select="child::*[contains(@class, $CLASS_INDEX_SEEALSO)]"
                                     mode="MAKE_INDEX_ORIGIN">
                    <xsl:with-param name="prmFoIndexKey"    select="$currentFoIndexKey"/>
                    <xsl:with-param name="prmIndexSortKey"  select="$currentIndexSortKey"/>
                    <xsl:with-param name="prmLevel"         select="$currentLevel"/>
                    <xsl:with-param name="prmIndexLabel"    select="$currentIndexLabel"/>
                    <xsl:with-param name="prmIndextermElem" select="$currentIndextermElement"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <!-- generate element for sorting -->
                <xsl:variable name="seq" as="xs:string">
                    <xsl:call-template name="genIndexSeq">
                        <xsl:with-param name="prmIndexterm" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="{$cIndexElementName}">
                    <!--xsl:attribute name="id">
                        <xsl:value-of select="ahf:generateId(.,$prmTopicRef)"/>
                    </xsl:attribute-->
                    <xsl:attribute name="group-label">
                        <xsl:value-of select="$currentIndexLabel"/>
                    </xsl:attribute>
                    <xsl:attribute name="indexkey">
                        <xsl:value-of select="$currentFoIndexKey"/>
                    </xsl:attribute>
                    <xsl:attribute name="level">
                        <xsl:value-of select="$currentLevel"/>
                    </xsl:attribute>
                    <xsl:attribute name="nestedindexterm">
                        <xsl:value-of select="'0'"/>
                    </xsl:attribute>
                    <xsl:attribute name="significance">
                        <xsl:value-of select="'normal'"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@xtrf"/>
                    <!-- Sortkey -->
                    <xsl:for-each select="$currentIndexSortKey">
                        <xsl:element name="{$cSortKeyElementName}">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:element name="{$cSortKeyElementName}">
                        <xsl:value-of select="concat(' ',$seq)"/>
                    </xsl:element>
                    <!--xsl:value-of select="$currentIndexSortKey"/>
                    <xsl:value-of select="' '"/--><!-- Sort indexterm only key first 2009/07/17 t.makita -->
                    <!--xsl:value-of select="$seq"/-->
                    <!-- indexterm data -->
                    <xsl:copy-of select="$currentIndextermElement"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function: index-see text template
     param:    See below
     return:   index-data nodeset
     note:     none
    -->
    <xsl:template match="*[contains(@class, ' indexing-d/index-see ')]" mode="MAKE_INDEX_ORIGIN">
        <xsl:param name="prmFoIndexKey"    required="yes" as="xs:string"/>
        <xsl:param name="prmIndexSortKey"  required="yes" as="xs:string*"/>
        <xsl:param name="prmLevel"         required="yes" as="xs:integer"/>
        <xsl:param name="prmIndexLabel"    required="yes" as="xs:string"/>
        <xsl:param name="prmIndextermElem" required="yes" as="element()*"/>
        
        <!-- index-see text -->
        <xsl:variable name="indexSeeText" as="xs:string">
            <xsl:variable name="tempIndexSeeText" as="xs:string*">
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndexSeeText"  tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space(string-join($tempIndexSeeText,''))"/>
        </xsl:variable>
        
        <!-- index-see FO -->
        <xsl:variable name="indexSeeFO" as="node()*">
            <fo:inline>
                <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
                <xsl:apply-templates>
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                    <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                    <xsl:with-param name="prmGetIndexSeeFO" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </fo:inline>
        </xsl:variable>
        
        <!-- index-see reference key -->
        <xsl:variable name="indexSeeKey" as="xs:string">
            <xsl:variable name="tempIndexSeeKey" as="xs:string*">
                <xsl:apply-templates select="." mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndexSeeKey" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space(string-join($tempIndexSeeKey,''))"/>
        </xsl:variable>
        
        <!-- Nested indexterm count -->
        <xsl:variable name="nestedIndexterm" select="count(descendant::*[contains(@class,$CLASS_INDEXTERM)])" as="xs:integer"/>
        
        <!-- generate element for sorting -->
        <xsl:variable name="seq" as="xs:string">
            <xsl:call-template name="genIndexSeq">
                <xsl:with-param name="prmIndexterm" select="parent::*"/>
            </xsl:call-template>
        </xsl:variable>
        
        
        <xsl:choose>
            <xsl:when test="not(parent::*/child::*[contains(@class, $CLASS_INDEXTERM)])">
                <xsl:element name="{$cIndexElementName}">
                    <!--xsl:attribute name="id">
                        <xsl:value-of select="ahf:generateId(.,$prmTopicRef)"/>
                    </xsl:attribute-->
                    <xsl:attribute name="group-label">
                        <xsl:value-of select="$prmIndexLabel"/>
                    </xsl:attribute>
                    <xsl:attribute name="indexkey">
                        <xsl:value-of select="$prmFoIndexKey"/>
                    </xsl:attribute>
                    <xsl:attribute name="level">
                        <xsl:value-of select="$prmLevel"/>
                    </xsl:attribute>
                    <xsl:attribute name="see">
                        <xsl:value-of select="$indexSeeText"/>
                    </xsl:attribute>
                    <xsl:attribute name="seekey">
                        <xsl:value-of select="$indexSeeKey"/>
                    </xsl:attribute>
                    <xsl:attribute name="nestedindexterm">
                        <xsl:value-of select="$nestedIndexterm"/>
                    </xsl:attribute>
                    <xsl:attribute name="significance">
                        <xsl:value-of select="'normal'"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@xtrf"/>
                    <!-- Sortkey -->
                    <xsl:for-each select="$prmIndexSortKey">
                        <xsl:element name="{$cSortKeyElementName}">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:element name="{$cSortKeyElementName}">
                        <xsl:value-of select="$indexSeeText"/>
                    </xsl:element>
                    <xsl:element name="{$cSortKeyElementName}">
                        <xsl:value-of select="$seq"/>
                    </xsl:element>
                    <!--xsl:value-of select="$prmIndexSortKey"/>
                    <xsl:value-of select="$indexSeeText"/>
                    <xsl:value-of select="$seq"/-->
                    <!-- indexterm data -->
                    <xsl:copy-of select="$prmIndextermElem"/>
                    <!-- index-see FO data -->
                    <xsl:element name="indexseefo">
                        <xsl:copy-of select="$indexSeeFO"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- Already error message is displayed. Ignore index-see. -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function: index-see-also text template
     param:    See below
     return:   index-data nodeset
     note:     none
    -->
    <xsl:template match="*[contains(@class, ' indexing-d/index-see-also ')]" mode="MAKE_INDEX_ORIGIN">
        <xsl:param name="prmFoIndexKey"    required="yes" as="xs:string"/>
        <xsl:param name="prmIndexSortKey"  required="yes" as="xs:string*"/>
        <xsl:param name="prmLevel"         required="yes" as="xs:integer"/>
        <xsl:param name="prmIndexLabel"    required="yes" as="xs:string"/>
        <xsl:param name="prmIndextermElem" required="yes" as="element()*"/>
        
        <!-- index-see text -->
        <xsl:variable name="indexSeeAlsoText" as="xs:string">
            <xsl:variable name="tempIndexSeeAlsoText" as="xs:string*">
                <xsl:apply-templates mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndexSeeText"  tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space(string-join($tempIndexSeeAlsoText,''))"/>
        </xsl:variable>
        
        <!-- index-see-also FO -->
        <xsl:variable name="indexSeeAlsoFO" as="node()*">
            <fo:inline>
                <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
                <xsl:apply-templates>
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                    <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                    <xsl:with-param name="prmGetIndexSeeFO" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </fo:inline>
        </xsl:variable>
        
        <!-- index-see-also reference key -->
        <xsl:variable name="indexSeeAlsoKey" as="xs:string">
            <xsl:variable name="tempIndexSeeAlsoKey" as="xs:string*">
                <xsl:apply-templates select="." mode="TEXT_ONLY">
                    <xsl:with-param name="prmGetIndexSeeKey" tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space(string-join($tempIndexSeeAlsoKey,''))"/>
        </xsl:variable>
        
        <!-- Nested indexterm count -->
        <xsl:variable name="nestedIndexterm" select="count(descendant::*[contains(@class,$CLASS_INDEXTERM)])" as="xs:integer"/>
        
        <!-- generate element for sorting -->
        <xsl:variable name="seq" as="xs:string">
            <xsl:call-template name="genIndexSeq">
                <xsl:with-param name="prmIndexterm" select="parent::*"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="not(parent::*/child::*[contains(@class, $CLASS_INDEXTERM)])">
                <xsl:element name="{$cIndexElementName}">
                    <!--xsl:attribute name="id">
                        <xsl:value-of select="ahf:generateId(.,$prmTopicRef)"/>
                    </xsl:attribute-->
                    <xsl:attribute name="group-label">
                        <xsl:value-of select="$prmIndexLabel"/>
                    </xsl:attribute>
                    <xsl:attribute name="indexkey">
                        <xsl:value-of select="$prmFoIndexKey"/>
                    </xsl:attribute>
                    <xsl:attribute name="level">
                        <xsl:value-of select="$prmLevel"/>
                    </xsl:attribute>
                    <xsl:attribute name="seealso">
                        <xsl:value-of select="$indexSeeAlsoText"/>
                    </xsl:attribute>
                    <xsl:attribute name="seealsokey">
                        <xsl:value-of select="$indexSeeAlsoKey"/>
                    </xsl:attribute>
                    <xsl:attribute name="nestedindexterm">
                        <xsl:value-of select="$nestedIndexterm"/>
                    </xsl:attribute>
                    <xsl:attribute name="significance">
                        <xsl:value-of select="'normal'"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@xtrf"/>
                    <!-- Sortkey -->
                    <xsl:for-each select="$prmIndexSortKey">
                        <xsl:element name="{$cSortKeyElementName}">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:element name="{$cSortKeyElementName}">
                        <xsl:value-of select="$indexSeeAlsoText"/>
                    </xsl:element>
                    <xsl:element name="{$cSortKeyElementName}">
                        <xsl:value-of select="$seq"/>
                    </xsl:element>
                    <!--xsl:value-of select="$prmIndexSortKey"/>
                    <xsl:value-of select="$indexSeeAlsoText"/>
                    <xsl:value-of select="$seq"/-->
                    <!-- indexterm data -->
                    <xsl:copy-of select="$prmIndextermElem"/>
                    <!-- index-see-also FO -->
                    <xsl:element name="indexseealsofo">
                        <xsl:copy-of select="$indexSeeAlsoFO"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- Already error message is displayed. Ignore index-see-also. -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- 
     function: Generate indexterm sequence number (Document order)
     param:    prmTopicRef, prmIndexterm
     return:   Sequence string
     note:     none
    -->
    <xsl:template name="genIndexSeq">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()"/>
        <xsl:param name="prmIndexterm" required="yes" as="element()"/>
        
        <xsl:variable name="isTopicRefIndexterm" select="boolean($prmIndexterm/ancestor::*[contains(@class,$CLASS_TOPICMETA)])" as="xs:boolean"/>
        <xsl:variable name="topicRefSeq">
            <xsl:number level="any" 
                        select="$prmIndexterm" 
                        from="*[contains(@class, ' map/map ')]" 
                        format="0000"/>
        </xsl:variable>
        <xsl:variable name="topicSeq">
            <xsl:choose>
                <xsl:when test="$isTopicRefIndexterm">
                    <xsl:number level="any" 
                                select="$prmIndexterm" 
                                from="*[contains(@class, $CLASS_TOPICMETA)]" 
                                format="0000"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number level="any" 
                                select="$prmIndexterm" 
                                from="*[contains(@class, ' topic/topic ')][parent::*[contains(@class,' map/map ')]]" 
                                format="0000"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$isTopicRefIndexterm">
                <xsl:value-of select="concat($topicRefSeq, '0', $topicSeq)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($topicRefSeq, '1', $topicSeq)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- 
     function: Dump indexterm sorted data
     param:    none
     return:   none
     note:     none
    -->
    <xsl:template name="dumpIndexterm">
        <xsl:for-each select="$indextermSorted/*">
            <xsl:message>[dumpIndexterm] seq='<xsl:value-of select="position()"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   id='<xsl:value-of select="@id"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   label='<xsl:value-of select="@group-label"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   indexkey='<xsl:value-of select="@indexkey"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   level='<xsl:value-of select="@level"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   see='<xsl:value-of select="@see"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   seekey='<xsl:value-of select="@seekey"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   seealso='<xsl:value-of select="@seealso"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   seealsokey='<xsl:value-of select="@seealsokey"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   nestedindexterm='<xsl:value-of select="@nestedindexterm"/>'</xsl:message>
            <xsl:message>[dumpIndexterm]   indexsortkey=<xsl:for-each select="key"><xsl:text> '</xsl:text><xsl:value-of select="."/><xsl:text>'</xsl:text></xsl:for-each>'
            </xsl:message>
            <xsl:for-each select="./indexterm">
                <xsl:message>[dumpIndexterm]   sub-seq='<xsl:value-of select="position()"/>'</xsl:message>
                <xsl:message>[dumpIndexterm]     sortas='<xsl:value-of select="@sortas"/>'</xsl:message>
                <xsl:message>[dumpIndexterm]     indexterm='<xsl:value-of select="text()"/>'</xsl:message>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function: Generate a indexterm label
     param:    prmIndexContent: Indexterm text itself.
     return:   Indexterm label
     note:     Language support is limited.
    -->
    <!-- Variables for making 'ja' index -->
    <xsl:variable name="aKana"  select="'あいうえおぁぃぅぇぉゔ'" as="xs:string"/>
    <xsl:variable name="kaKana" select="'かきくけこがぎぐげご'" as="xs:string"/>
    <xsl:variable name="saKana" select="'さしすせそざじずぜぞ'" as="xs:string"/>
    <xsl:variable name="taKana" select="'たちつてとだぢづでどっ'" as="xs:string"/>
    <xsl:variable name="naKana" select="'なにぬねの'" as="xs:string"/>
    <xsl:variable name="haKana" select="'はひふへほばびぶべぼぱぴぷぺぽ'" as="xs:string"/>
    <xsl:variable name="maKana" select="'まみむめも'" as="xs:string"/>
    <xsl:variable name="yaKana" select="'やゆよゃゅょ'" as="xs:string"/>
    <xsl:variable name="raKana" select="'らりるれろ'" as="xs:string"/>
    <xsl:variable name="waKana" select="'わゐゑをゎ'" as="xs:string"/>
    <xsl:variable name="nKana"  select="'ん'" as="xs:string"/>
    
    <xsl:template name="getIndexLabel">
        <xsl:param name="prmIndexContent" required="yes" as="xs:string"/>
    
        <xsl:variable name="firstChar" select="substring($prmIndexContent,1,1)" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($documentLang,'en-') or $documentLang='en'">
                <xsl:choose>
                    <!-- Does first char matches any upper case character? -->
                    <xsl:when test="matches(upper-case($firstChar),'\p{Lu}')">
                        <xsl:value-of select="upper-case($firstChar)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$cIndexSymbolLabel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="starts-with($documentLang,'ja-') or $documentLang='ja'">
                <xsl:choose>
                    <xsl:when test="contains($aKana, $firstChar)">
                        <xsl:value-of select="substring($aKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($kaKana, $firstChar)">
                        <xsl:value-of select="substring($kaKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($saKana, $firstChar)">
                        <xsl:value-of select="substring($saKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($taKana, $firstChar)">
                        <xsl:value-of select="substring($taKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($naKana, $firstChar)">
                        <xsl:value-of select="substring($naKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($haKana, $firstChar)">
                        <xsl:value-of select="substring($haKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($maKana, $firstChar)">
                        <xsl:value-of select="substring($maKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($yaKana, $firstChar)">
                        <xsl:value-of select="substring($yaKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($raKana, $firstChar)">
                        <xsl:value-of select="substring($raKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($waKana, $firstChar)">
                        <xsl:value-of select="substring($waKana, 1, 1)"/>
                    </xsl:when>
                    <xsl:when test="contains($nKana, $firstChar)">
                        <xsl:value-of select="substring($nKana,  1, 1)"/>
                    </xsl:when>
                    <xsl:when test="matches(upper-case($firstChar),'\p{Lu}')">
                        <xsl:value-of select="upper-case($firstChar)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$cIndexSymbolLabel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Unsupported language -->
                <xsl:value-of select="upper-case($firstChar)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

