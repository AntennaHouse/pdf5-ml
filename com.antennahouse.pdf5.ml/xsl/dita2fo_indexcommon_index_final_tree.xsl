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
     exclude-result-prefixes="xs ahf axf"
    >

    <!-- *************************************** 
            Index Sorting Final Result Tree
         ***************************************-->
    
    <!-- 
         Function: Generate final index-data result tree
         Param:    none
         Return:   document-node() 
         Note:     See the result by applying debug.index="yes" in DITA-OT build.
                   Then the sorting/grouping result will be appeared in output folder as:
                   $indextermOrigin.xml
                   $indextermSorted.xml
                   $indextermFinalSortedTree.xml (This template generates)
                   index-data is the representation of a set of indexterm passed from DITA source.
      -->
    <xsl:variable name="indextermFinalSortedTree" as="document-node()">
        <xsl:document>
            <xsl:call-template name="genFinalIndexTree">
                <xsl:with-param name="prmIndexData" select="$indextermSorted/*"/>
            </xsl:call-template>
        </xsl:document>
    </xsl:variable>
    
    <!-- 
         Function: Generate final index-data result tree
         Param:    $prmIndexdata (index-data element in middle XML fragment tree)
         Return:   element()* 
         Note:     Not all attributes were written.
                   No-I18n Index Library:
                     @group-label
                   I18n Index Library:
                     @group-key
                     @group-label
                     @group-sort-key
      -->
    <xsl:template name="genFinalIndexTree" as="element()*">
        <xsl:param name="prmIndexData" as="element()*" required="yes"/>
        
        <xsl:for-each-group select="$prmIndexData" group-adjacent="@group-label">
            <index-group-label>
                <xsl:attribute name="group-key"      select="current-group()[1]/@group-key => string()"/>
                <xsl:attribute name="group-label"    select="current-group()[1]/@group-label => string()"/>
                <xsl:attribute name="group-sort-key" select="current-group()[1]/@group-sort-key => string()"/>
                <xsl:call-template name="groupIndexDataByNthIndexKey">
                    <xsl:with-param name="prmIndexData" select="current-group()"/>
                    <xsl:with-param name="prmIndexKeyLevel" select="1"/>
                </xsl:call-template>
            </index-group-label>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- 
         Function: Group index-data by it's Nth indexterm's indexkey
         Param:    $prmIndexData
         Return:   element()* 
         Note:     Add @indexkeyForSee and @level to <index-group>
      -->
    <xsl:template name="groupIndexDataByNthIndexKey" as="element()*">
        <xsl:param name="prmIndexData" as="element()*" required="yes"/>
        <xsl:param name="prmIndexKeyLevel" as="xs:integer" required="yes"/>
        <xsl:for-each-group select="$prmIndexData" group-adjacent="ahf:getNthIndexKeyFromIndexData(.,$prmIndexKeyLevel)">
            <xsl:variable name="indexDataGroup" as="element()+" select="current-group()"/>
            <xsl:variable name="hasLevelPlusOneIndexData" select="some $indexData in $indexDataGroup satisfies ahf:hasNthIndexKeyInIndexData($indexData,$prmIndexKeyLevel + 1)"/>
            <index-group>
                <xsl:attribute name="group-key" select="current-grouping-key()"/>
                <xsl:attribute name="level" select="$prmIndexKeyLevel => string()"/>
                <xsl:attribute name="indexkeyForSee" select="ahf:getNthLevelIndexKey($indexDataGroup[1]/@indexkeyForSee => string(), $prmIndexKeyLevel)"/>
                <xsl:attribute name="isLast" select="if ($hasLevelPlusOneIndexData) then 'no' else 'yes'"/>
                <xsl:copy-of select="$indexDataGroup[1]/indexterm[$prmIndexKeyLevel]/indextermfo"/>
                <xsl:choose>
                    <xsl:when test="$hasLevelPlusOneIndexData">
                        <xsl:for-each-group select="$indexDataGroup" group-adjacent="ahf:hasNthIndexKeyInIndexData(.,$prmIndexKeyLevel + 1)">
                            <xsl:variable name="hasNPlus1Key" as="xs:boolean" select="current-grouping-key()"/>
                            <xsl:choose>
                                <xsl:when test="$hasNPlus1Key">
                                    <xsl:call-template name="groupIndexDataByNthIndexKey">
                                        <xsl:with-param name="prmIndexData"     select="current-group()"/>
                                        <xsl:with-param name="prmIndexKeyLevel" select="$prmIndexKeyLevel + 1"/>
                                    </xsl:call-template>                        
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="groupIndexDataBySeeOrSeeAlso">
                                        <xsl:with-param name="prmIndexData" select="current-group()"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="groupIndexDataBySeeOrSeeAlso">
                            <xsl:with-param name="prmIndexData" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </index-group>           
        </xsl:for-each-group>        
    </xsl:template>
    
    <!-- 
         Function: Get Nth indexkey from index-data element
         Param:    $prmIndexData
         Return:   xs:string 
         Note:     
      -->
    <xsl:function name="ahf:getNthIndexKeyFromIndexData" as="xs:string">
        <xsl:param name="prmIndexData" as="element()"/>
        <xsl:param name="prmNth" as="xs:integer"/>
        <xsl:variable name="indexKey" as="xs:string" select="$prmIndexData/@indexkey => string()"/>
        <xsl:variable name="indexKeys" as="xs:string*" select="tokenize($indexKey,$indexKeySep)"/>
        <xsl:variable name="result" as="xs:string?" select="$indexKeys[$prmNth]"/>
        <xsl:sequence select="if ($result => empty()) then '' else $result"/>
    </xsl:function>
    
    <xsl:function name="ahf:hasNthIndexKeyInIndexData" as="xs:boolean">
        <xsl:param name="prmIndexData" as="element()"/>
        <xsl:param name="prmNth" as="xs:integer"/>
        <xsl:variable name="indexKey" as="xs:string" select="$prmIndexData/@indexkey => string()"/>
        <xsl:variable name="indexKeys" as="xs:string*" select="tokenize($indexKey,$indexKeySep)"/>
        <xsl:variable name="result" as="xs:string?" select="$indexKeys[$prmNth]"/>
        <xsl:sequence select="if ($result => empty()) then false() else true()"/>
    </xsl:function>

    <!-- 
         Function: Get Nth level indexkeyForSee from @indexkeyForSee
         Param:    prmIndexKey, prmLevel
         Return:   xs:string 
         Note:     prmIndexKey is delimited by indexKeySep
      -->
    <xsl:function name="ahf:getNthLevelIndexKey" as="xs:string">
        <xsl:param name="prmIndexKey" as="xs:string"/>
        <xsl:param name="prmLevel"    as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$prmLevel eq 1 and contains($prmIndexKey,$indexKeySep) => not()">
                <xsl:sequence select="$prmIndexKey"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="indexKeys" as="xs:string+" select="tokenize($prmIndexKey,$indexKeySep)"/>
                <xsl:variable name="result" as="xs:string" select="$indexKeys[position() le $prmLevel] => string-join($indexKeySep)"/>
                <xsl:sequence select="$result"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
         Function: Group index-data by @see and @seealso and combine them one index-data
         Param:    $prmIndexTerms
         Return:   element()* 
         Note:     Use XSLT 3.0 xsl:for-each-group/@composite="yes" 
      -->
    <xsl:template name="groupIndexDataBySeeOrSeeAlso" as="element()*">
        <xsl:param name="prmIndexData" as="element()*" required="yes"/>
        <xsl:for-each-group select="$prmIndexData" group-adjacent="ahf:getSeeAndSeeAlsoKeyFromIndexData(.)" composite="yes">
            <xsl:sequence select="current-group()[1]"/>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- 
         Function: Get topicref no, href, see as key from indexterm (index-data element)
         Param:    $prmIndexTerm
         Return:   xs:string+ 
         Note:     If index-data is grouped by Nth indexterm's indexkey, the remaining key is @seekey and @seealsokey
      -->
    <xsl:function name="ahf:getSeeAndSeeAlsoKeyFromIndexData" as="xs:string+">
        <xsl:param name="prmIndexData" as="element()"/>
        <xsl:variable name="seeKey" as="xs:string" select="$prmIndexData/@seekey => string()"/>
        <xsl:variable name="seeAlsoKey" as="xs:string" select="$prmIndexData/@seealsokey => string()"/>
        <xsl:sequence select="($seeKey, $seeAlsoKey)"/>
    </xsl:function>

</xsl:stylesheet>
