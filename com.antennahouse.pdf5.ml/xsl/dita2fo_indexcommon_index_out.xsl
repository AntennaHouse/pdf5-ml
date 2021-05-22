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
     xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
     exclude-result-prefixes="xs ahf axf"
    >
    <!-- *************************************** 
            Keys
         ***************************************-->
    <!-- index-see, index-see-also key -->
    <xsl:key name="indextermBySee" match="$indextermSorted/index-data" use="@seekey"/>
    <xsl:key name="indextermBySeeAlso" match="$indextermSorted/index-data" use="@seealsokey"/>
    
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

    <!-- indexkey for @significance="preferred" (DocBook Only) -->
    <xsl:variable name="KEY_PREFERRED" select="'__KEY_PREFERRED'" as="xs:string"/>
    
    <!-- Sort key max length (When stylesheet does not use I18n Index Library) -->
    <xsl:variable name="cIndexSortKeyMaxLen" select="128" as="xs:integer"/>
    
    <!-- index-key separator -->
    <!--xsl:variable name="indexKeySep" select="':'"/-->
    
    <!-- index id prefix -->
    <xsl:variable name="cIndexKeyPrefix" select="'__indexkey'"/>
    
    <!-- 
         Function: Make index page sequence
         Param:    none.
         Return:   fo:page-sequence 
         Note:     Current is booklists/indexlist
      -->
    <xsl:template name="genIndex">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="id" as="xs:string" select="string(ahf:getIdAtts($topicRef,$topicRef,true())[1])"/>
        
        <!-- Inform new module -->
        <xsl:message select="'[INFO][genIndex] Running on refined XSLT 3.0 index processing module.'"/>
        
    	<!-- debug -->
    	<xsl:if test="$indextermOriginCount != $indextermSortedCount">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes" 
                 select="ahf:replace($stMes600,('%before','%after'),(string($indextermOriginCount),string($indextermSortedCount)))"/>
            </xsl:call-template>
    	</xsl:if>
    
        <xsl:if test="$pDebugIndex">
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" select="$stMes601"/>
            </xsl:call-template>
            <xsl:result-document href="{concat($pOutputDirUrl,$pInputMapName,'_index_input.xml')}" encoding="UTF-8" byte-order-mark="no" indent="yes">
                <index-input>
                    <xsl:copy-of select="$indextermOrigin"/>
                </index-input>
            </xsl:result-document>
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
        
        <!-- Current index-data & @id generation variables
             2021-05-22 t.makita
         -->
        <xsl:variable name="indexData" as="element()" select="$indextermSorted/index-data[@id => string() eq $prmCurrentId]"/>
        <xsl:variable name="indexKeyForSee"  as="xs:string" select="string($indexData/@indexkeyForSee)"/>
        <xsl:variable name="isReferenced" as="xs:boolean" select="key('indextermBySee', $indexKeyForSee, $indextermSorted) => exists() or key('indextermBySeeAlso', $indexKeyForSee, $indextermSorted) => exists()"/>
        <xsl:variable name="isFirstOccurence" as="xs:boolean" select="$indexData/preceding-sibling::index-data[@indexkeyForSee  => string() eq $indexKeyForSee] => empty()"/>
        <!--xsl:message select="'$indexKeyForSee=' || $indexKeyForSee"/>
        <xsl:message select="'$indexKeyForSeeID=' || ahf:indexKeyToIdValue($indexKeyForSee)"/>
        <xsl:message select="'key(''indextermBySee'', $indexKeyForSee, $indextermSorted)=', key('indextermBySee', $indexKeyForSee, $indextermSorted)"/>
        <xsl:message select="'key(''indextermBySeeAlso'', $indexKeyForSee, $indextermSorted)=', key('indextermBySeeAlso', $indexKeyForSee, $indextermSorted)"/>
        <xsl:message select="'$isReferenced=' || $isReferenced => string()"/>
        <xsl:message select="'$isFirstOccurence=' || $isFirstOccurence => string()"/-->
        <xsl:variable name="shouldGenerateId" as="xs:boolean" select="$pMakeSeeLink and $isReferenced and $isFirstOccurence"/>
        
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
                    <xsl:if test="string($currentLevelIndexkeyId) and $shouldGenerateId">
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
                        <!-- Generate @id only when it is referenced via index-see or index-see-also
                             2021-05-22 t.makita
                          -->
                        <xsl:if test="$shouldGenerateId">
                            <!-- Make @id from @indexKeyForSee, because it has no index-sort-as content.
                                 2019-11-03 t.makita
                             -->
                            <xsl:attribute name="id">
                                <xsl:value-of select="ahf:indexKeyToIdValue($indexKeyForSee)"/>
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
            param:  prmId, prmLevel
            return: index-data[@id=$prmId]/indexterm[$prmLevel]/@indexkey
            note:   Change @indexKey to @indexkeyForSee to make <index-see>, <index-see-also> link correctly.
                    2019-11-03 t.makita
    -->
    <xsl:function name="ahf:getCurrentLevelIndexKey" as="xs:string">
        <xsl:param name="prmId" as="xs:string"/>
        <xsl:param name="prmLevel" as="xs:integer"/>
        <xsl:variable name="indexkeyForSee" select="string($indextermSorted/index-data[@id=$prmId]/indexterm[$prmLevel]/@indexkeyForSee)" as="xs:string"/>
        <xsl:choose>
        	<xsl:when test="$indextermSorted/index-data[@id=$prmId]/preceding-sibling::index-data/indexterm[$prmLevel][string(@indexkeyForSee) eq $indexkeyForSee ]">
        		<xsl:sequence select="''"/>
        	</xsl:when>
        	<xsl:otherwise>
        		<xsl:sequence select="$indexkeyForSee"/>
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

    <!-- 
	     indexDump template
	     function: Save $indextermOrigin, $indextermSorted to file for debugging.
	     param: none
	     note:
	  -->
    <xsl:template name="indexDump">
        <xsl:message>[indexDump] Saving $indextermOrigin, $indextermSorted to file.</xsl:message>
        
        <!-- $indextermOrigin -->
        <xsl:result-document 
            method="xml" 
            encoding="UTF-8" 
            byte-order-mark="no"
            indent="yes"
            href="{concat($pOutputDirUrl,'$indextermOrigin.xml')}">
            <root>
                <xsl:copy-of select="$indextermOrigin"/>
            </root>
        </xsl:result-document>
        <xsl:result-document 
            method="xml" 
            encoding="UTF-8" 
            byte-order-mark="no"
            indent="yes"
            href="{concat($pOutputDirUrl,'$indextermSorted.xml')}">
            <root>
                <xsl:copy-of select="$indextermSorted"/>
            </root>
        </xsl:result-document>
        
    </xsl:template>
    
</xsl:stylesheet>
