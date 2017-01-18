<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Table templates
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
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
 exclude-result-prefixes="xs ahf ahs"
>
    <!-- **************************** 
            Table Templates
         ****************************-->
    <!-- 
     function:	table[@orient="land"] template
     param:	    
     return:	fo:bloc-container
     note:		Table will be located by 90 degrees counterclockwise from the text flow.
     -->
    <xsl:template match="*[contains(@class, ' topic/table ')][string(@orient) eq 'land']" priority="4">
        <fo:block-container>
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="'atsBlockContainerForLandscapeTable'"/>
            </xsl:call-template>
            <xsl:next-match/>
        </fo:block-container>
    </xsl:template>

    <!-- 
     function:	table[@pgwide="1"] template
     param:	    
     return:	fo:bloc-container
     note:		Table will be positioned from left page margin to right page margin.
                Change implementation method to force table width to full.
                2016-09-23 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/table ')][string(@pgwide) eq '1']" priority="2">
        <fo:block-container>
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="'atsBlockContainerForPgWideTable'"/>
            </xsl:call-template>
            <xsl:next-match/>
        </fo:block-container>
    </xsl:template>

    <!-- 
     function:	table template
     param:	    
     return:	fo:wrapper
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/table ')]">
        <xsl:variable name="tableAttr" select="ahf:getTableAttr(.)" as="element()"/>
        <fo:wrapper>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:if test="empty(@id) and child::*[contains(@class, ' topic/title ')]">
                <xsl:call-template name="ahf:generateIdAttr"/>
            </xsl:if>
            <xsl:if test="not($pOutputTableTitleAfter)">
                <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
            </xsl:if>
            <xsl:apply-templates select="*[contains(@class, ' topic/desc ')]"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]">
                <xsl:with-param name="prmTableAttr" select="$tableAttr"/>
            </xsl:apply-templates>
            <xsl:if test="not($pDisplayFnAtEndOfTopic)">
                <xsl:call-template name="makeFootNote">
                    <xsl:with-param name="prmElement"  select="."/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$pOutputTableTitleAfter">
                <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
            </xsl:if>
        </fo:wrapper>
    </xsl:template>
    
    <!-- 
     function:	build table attributes
     param:		prmTable
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:getTableAttr" as="element()">
        <xsl:param name="prmTable" as="element()"/>
        <dummy>
            <xsl:attribute name="frame"  select="if (exists($prmTable/@frame))  then string($prmTable/@frame) else 'all'"/>
            <xsl:attribute name="colsep" select="if (exists($prmTable/@colsep)) then string($prmTable/@colsep) else '1'"/>
            <xsl:attribute name="rowsep" select="if (exists($prmTable/@rowsep)) then string($prmTable/@rowsep) else '1'"/>
            <xsl:attribute name="pgwide" select="if (exists($prmTable/@pgwide)) then string($prmTable/@pgwide) else '0'"/>
            <xsl:attribute name="rowheader" select="if (exists($prmTable/@rowheader)) then string($prmTable/@rowheader) else 'norowheader'"/>
            <xsl:attribute name="scale"  select="if (exists($prmTable/@scale))  then string($prmTable/@scale) else '100'"/>
            <xsl:copy-of select="$prmTable/@class"/>
            <xsl:copy-of select="$prmTable/@fo:prop"/>
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	table/desc template
     param:	    
     return:	fo:block
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/desc ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsTableDesc'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/desc ')]">
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	table/title template
     param:	    
     return:	fo:block
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')][$pOutputTableTitleAfter]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsTableTitleAfter'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')][not($pOutputTableTitleAfter)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsTableTitleBefore'"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')]" priority="2">
        <xsl:variable name="tableTitlePrefix" as="xs:string">
            <xsl:call-template name="ahf:getTableTitlePrefix">
                <xsl:with-param name="prmTable" select="parent::*[1]"/>
            </xsl:call-template>
        </xsl:variable>
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:value-of select="$tableTitlePrefix"/>
            <xsl:text>&#x00A0;</xsl:text>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	tgroup template
     param:	    prmTableAttr
     return:	fo:table
     note:		Add space-before when there is no table/tite,desc.
                2016-07-24 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/tgroup ')][$pOutputTableTitleAfter]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsTableWithTitleAfter'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/tgroup ')][not($pOutputTableTitleAfter)]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsTableWithTitleBefore'"/>
        <xsl:if test="parent::*[empty(child::*[contains(@class,' topic/title ')])][empty(child::*[contains(@class,' topic/desc ')])]">
            <xsl:sequence select="'atsTableWithTitleBeforeWoTitleAndDesc'"/>
        </xsl:if>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/tgroup ')]">
        <xsl:param name="prmTableAttr" required="yes" as="element()"/>
    
        <xsl:variable name="tgroupAttr" select="ahf:addTgroupAttr(.,$prmTableAttr)" as="element()"/>
        <xsl:variable name="colSpec" as="element()*">
            <xsl:apply-templates select="child::*[contains(@class, ' topic/colspec ')]">
                <xsl:with-param name="prmTgroupAttr" select="$tgroupAttr"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="tableAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:table-and-caption>
            <xsl:copy-of select="ahf:getFoStyleAndProperty($tgroupAttr)[name() eq 'text-align']"/>
            <fo:table>
                <xsl:copy-of select="$tableAttr"/>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:call-template name="ahf:getTablePgwideAttr ">
                    <xsl:with-param name="prmTgroupAttr" select="$tgroupAttr"/>
                </xsl:call-template>
                <xsl:copy-of select="ahf:getScaleAtts($tgroupAttr,$tableAttr)"/>
                <xsl:copy-of select="ahf:getFrameAtts($tgroupAttr,$tableAttr)"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty($tgroupAttr)[name() ne 'text-align']"/>
                <!-- Copy fo:table-column -->
                <xsl:apply-templates select="$colSpec" mode="COPY_COLSPEC"/>
                <xsl:apply-templates select="*[contains(@class, ' topic/thead ')]">
                    <xsl:with-param name="prmTgroupAttr" select="$tgroupAttr"/>
                    <xsl:with-param name="prmColSpec"    select="$colSpec"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="*[contains(@class, ' topic/tbody ')]">
                    <xsl:with-param name="prmTgroupAttr" select="$tgroupAttr"/>
                    <xsl:with-param name="prmColSpec"    select="$colSpec"/>
                </xsl:apply-templates>
            </fo:table>
        </fo:table-and-caption>
    </xsl:template>
    
    <!-- 
     function:	build tgroup attributes
     param:		prmTgroup, prmTableAttr
     return:	element()
     note:		@fo:prop is only used to separate text-align because it is only applied to fo:table-and-caption.
                2016-02-26 t.makita
     -->
    <xsl:function name="ahf:addTgroupAttr" as="element()">
        <xsl:param name="prmTgroup"    as="element()"/>
        <xsl:param name="prmTableAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmTableAttr/@*"/>
            <xsl:attribute name="cols" select="string($prmTgroup/@cols)"/>
            <xsl:copy-of select="$prmTgroup/@colsep"/>
            <xsl:copy-of select="$prmTgroup/@rowsep"/>
            <xsl:copy-of select="$prmTgroup/@align"/>
            <xsl:copy-of select="$prmTgroup/@fo:prop"/>"
        </dummy>
    </xsl:function>

    <!-- 
     function:	Get pgwide attributes
     param:		prmTgroupAttr
     return:	attribute()
     note:		
     -->
    <xsl:template name="ahf:getTablePgwideAttr" as="attribute()*">
        <xsl:param name="prmTgroupAttr"    as="element()"/>
        <xsl:if test="string($prmTgroupAttr/@pgwide) eq '1'">
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" select="'atsPgWideTable'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- 
     function:	fo:table-column copy template
     param:		none
     return:	fo:table-column
     note:		
     -->
    <xsl:template match="fo:table-column" mode="COPY_COLSPEC">
        <xsl:copy>
            <xsl:copy-of select="@*[name() ne 'ahf:column-name']"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:	colspec template
     param:	    prmTgroupAttr
     return:	fo:table-column
     note:		Added border style "atsTableColumn" to set default border width. 2014-01-03 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/colspec ')]">
        <xsl:param name="prmTgroupAttr" required="yes" as="element()"/>
    
        <fo:table-column>
            <xsl:copy-of select="ahf:getAttributeSet('atsTableColumn')"/>
            <xsl:copy-of select="ahf:getColSpecAttr(.)"/>
            <xsl:copy-of select="ahf:getLocalizationAtts(.)"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
        </fo:table-column>
    </xsl:template>
    
    <!-- 
     function:	build colspec attributes
     param:		prmColSpec
     return:	attribute()*
     note:		Generates XSL-FO property.
     -->
    <xsl:function name="ahf:getColSpecAttr" as="attribute()*">
        <xsl:param name="prmColSpec"    as="element()"/>
    
        <!-- colname (Not defined in XSL-FO)-->
        <xsl:if test="exists($prmColSpec/@colname)">
            <xsl:attribute name="ahf:column-name" select="string($prmColSpec/@colname)"/>
        </xsl:if>
    
        <!-- colnum -->
        <xsl:choose>
            <xsl:when test="exists($prmColSpec/@colnum)">
                <xsl:attribute name="column-number" select="string($prmColSpec/@colnum)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="column-number" select="string(count($prmColSpec/preceding-sibling::*[contains(@class,' topic/colspec ')])+1)"/>
            </xsl:otherwise>
        </xsl:choose>
    
        <!-- colwidth -->
        <xsl:if test="exists($prmColSpec/@colwidth)">
            <xsl:variable name="colWidth">
                <xsl:call-template name="calc.column.width">
                    <xsl:with-param name="colwidth" select="string($prmColSpec/@colwidth)"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="column-width" select="string($colWidth)"/>
        </xsl:if>
        
        <!-- colsep -->
        <xsl:if test="exists($prmColSpec/@colsep)">
            <xsl:variable name="colsep" as="xs:string" select="string($prmColSpec/@colsep)"/>
            <xsl:choose>
                <xsl:when test="$colsep eq '0'">
                    <xsl:attribute name="border-end-style" select="'none'"/>
                </xsl:when>
                <xsl:when test="$colsep eq '1'">
                    <xsl:attribute name="border-end-style" select="'solid'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    
        <!-- rowsep -->
        <xsl:if test="exists($prmColSpec/@rowsep)">
            <xsl:variable name="rowsep" as="xs:string" select="string($prmColSpec/@rowsep)"/>
            <xsl:choose>
                <xsl:when test="$rowsep eq '0'">
                    <xsl:attribute name="border-after-style" select="'none'"/>
                </xsl:when>
                <xsl:when test="$rowsep eq '1'">
                    <xsl:attribute name="border-after-style" select="'solid'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        
        <!-- align -->
        <xsl:if test="exists($prmColSpec/@align)">
            <xsl:variable name="align" as="xs:string" select="string($prmColSpec/@align)"/>
            <xsl:choose>
                <xsl:when test="$align eq 'char'">
                    <xsl:variable name="char" select="string($prmColSpec/@char)"/>
                    <!--xsl:variable name="charoff" select="string($prmColSpec/@charoff)"/-->
                    <xsl:choose>
                        <xsl:when test="string($char)">
                            <xsl:attribute name="text-align" select="$char"/>
                            <!--xsl:if test="string($charoff)">
                                <xsl:attribute name="start-indent" select="concat($charoff,'%')"/>
                            </xsl:if-->
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="text-align" select="$align"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        
    </xsl:function>
    
    <!-- 
     function:	thead template
     param:		prmTgroupAttr, prmColSpec
     return:	fo:table-header
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/thead ')]">
        <xsl:param name="prmTgroupAttr" required="yes"  as="element()"/>
        <xsl:param name="prmColSpec" required="yes" as="element()*"/>
    
        <xsl:variable name="theadAttr" select="ahf:addTheadAttr(.,$prmTgroupAttr)" as="element()"/>
        <fo:table-header>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsThead'"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/row ')]">
                <xsl:with-param name="prmRowUpperAttr"   select="$theadAttr"/>
                <xsl:with-param name="prmColSpec"    select="$prmColSpec"/>
            </xsl:apply-templates>
        </fo:table-header>
    </xsl:template>
    
    <!-- 
     function:	build thead attributes
     param:		prmThead, prmTgroupAttr
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:addTheadAttr" as="element()">
        <xsl:param name="prmThead"    as="element()"/>
        <xsl:param name="prmTgroupAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmTgroupAttr/@* except $prmTgroupAttr/@fo:prop"/>
            <xsl:copy-of select="$prmThead/@valign"/>
            <xsl:copy-of select="ahf:getStylesheetProperty($prmThead)"/>"
        </dummy>
    </xsl:function>
    
    
    <!-- 
     function:	tbody template
     param:		prmTgroupAttr, prmColSpec
     return:	fo:table-body
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/tbody ')]">
        <xsl:param name="prmTgroupAttr" required="yes" as="element()"/>
        <xsl:param name="prmColSpec" required="yes" as="element()*"/>
    
        <xsl:variable name="tbodyAttr" select="ahf:addTbodyAttr(.,$prmTgroupAttr)" as="element()"/>
        <fo:table-body>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsTbody'"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/row ')]">
                <xsl:with-param name="prmRowUpperAttr" select="$tbodyAttr"/>
                <xsl:with-param name="prmColSpec"    select="$prmColSpec"/>
            </xsl:apply-templates>
        </fo:table-body>
    </xsl:template>


    <!-- 
     function:	build tbody attributes
     param:		prmTbody, prmTgroupAttr
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:addTbodyAttr" as="element()">
        <xsl:param name="prmTbody"    as="element()"/>
        <xsl:param name="prmTgroupAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmTgroupAttr/@* except $prmTgroupAttr/@fo:prop"/>
            <xsl:copy-of select="$prmTbody/@valign"/>
            <xsl:copy-of select="ahf:getStylesheetProperty($prmTbody)"/>"
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	row template
     param:		prmRowUpperAttr, prmColSpec
     return:	fo:table-row
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/row ')]">
        <xsl:param name="prmRowUpperAttr" required="yes" as="element()"/>
        <xsl:param name="prmColSpec" required="yes" as="element()*"/>
    
        <xsl:variable name="rowAttr" select="ahf:addRowAttr(.,$prmRowUpperAttr)" as="element()"/>
        <xsl:variable name="rowHeight" as="xs:double">
            <xsl:call-template name="getRowHeight">
                <xsl:with-param name="prmRow" select="."/>
                <xsl:with-param name="prmRowAttr" select="$rowAttr"/>
            </xsl:call-template>
        </xsl:variable>
        <fo:table-row>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsRow'"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:if test="$rowHeight gt 0.0">
                <xsl:attribute name="height" select="concat(string($rowHeight),'em')"/>
            </xsl:if>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/entry ')]">
                <xsl:with-param name="prmRowAttr"    select="$rowAttr"/>
                <xsl:with-param name="prmColSpec"    select="$prmColSpec"/>
                <xsl:with-param name="prmRowHeight"  select="$rowHeight"/>
            </xsl:apply-templates>
        </fo:table-row>
    </xsl:template>
    
    <!-- 
     function:	build row attributes
     param:		prmRow, prmRowUpperAttr
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:addRowAttr" as="element()">
        <xsl:param name="prmRow"    as="element()"/>
        <xsl:param name="prmRowUpperAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmRowUpperAttr/@*"/>
            <xsl:copy-of select="$prmRow/@rowsep"/>
            <xsl:copy-of select="$prmRow/@valign"/>
            <xsl:copy-of select="ahf:getStylesheetProperty($prmRow)"/>
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	get row height considering entry/@rotate="1"
     param:		prmRow, prmRowAttr
     return:	xs:double (Row height as em unit. 0.0 means no needs to set row height)
     note:		
     -->
    <xsl:template name="getRowHeight" as="xs:double">
        <xsl:param name="prmRow" as="element()" required="yes"/>
        <xsl:param name="prmRowAttr" as="element()" required="yes"/>
        <xsl:variable name="rotatedEntries" as="element()*" select="$prmRow/*[contains(@class,' topic/entry ')][string(@rotate) eq '1']"/>
        <xsl:choose>
            <xsl:when test="exists($rotatedEntries)">
                <!-- Average character width in table cell -->
                <xsl:variable name="avgCharWidthInTableCell" as="xs:double">
                    <!-- Manually specified row charracter width -->
                    <xsl:variable name="maunuallySpecifiedCharWidth" as="xs:double?" select="xs:double($prmRowAttr/@*[name() eq 'ahs:avg-char-width-in-table-entry'])"/>
                    <xsl:choose>
                        <xsl:when test="exists($maunuallySpecifiedCharWidth)">
                            <xsl:sequence select="$maunuallySpecifiedCharWidth"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getVarValueAsDouble">
                                <xsl:with-param name="prmVarName" select="'Avg_Char_Width_In_Table_Entry'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>    
                </xsl:variable>
                <!-- Max character count in rotated entry -->
                <xsl:variable name="maxCharCountInRotatedTableEntry" as="xs:double">
                    <!-- Manually specified row height -->
                    <xsl:variable name="maunuallyAssignRowHeight" as="xs:double?" select="xs:double($prmRowAttr/@*[name() eq 'ahs:max-char-count-in-rotated-table-entry'])"/>
                    <xsl:message select="'ahf:getStylesheetProperty($prmRowAttr)=',ahf:getStylesheetProperty($prmRowAttr)"/>
                    <xsl:choose>
                        <xsl:when test="exists($maunuallyAssignRowHeight)">
                            <xsl:sequence select="$maunuallyAssignRowHeight"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getVarValueAsDouble">
                                <xsl:with-param name="prmVarName" select="'Max_Char_Count_In_Rotated_Table_Entry'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!-- Row height in em unit -->
                <xsl:variable name="rowHeights" as="xs:double+">
                    <xsl:for-each select="$rotatedEntries">
                        <xsl:variable name="rotatedEntry" as="element()" select="."/>
                        <!-- Entry character count -->
                        <xsl:variable name="rotatedEntryCharCount" as="xs:double">
                            <xsl:variable name="entryCharTexts" as="xs:string*">
                                <xsl:apply-templates select="$rotatedEntry" mode="TEXT_ONLY"/>
                            </xsl:variable>
                            <xsl:sequence select="xs:double(string-length(normalize-space(string-join($entryCharTexts,''))))"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$rotatedEntryCharCount gt $maxCharCountInRotatedTableEntry">
                                <xsl:sequence select="$maxCharCountInRotatedTableEntry * $avgCharWidthInTableCell"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$rotatedEntryCharCount * $avgCharWidthInTableCell"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:sequence select="max($rowHeights)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0.0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- 
     function:	entry template
     param:		prmRowAttr, prmColSpec,prmRowHeight
     return:	fo:table-cell
     note:		Honor the entry attribute than colspec attribute. 2011-08-29 t.makita
                $prmRowHeight is needed for entry/@rotate="1" when specifying fo:block-container/@width
     -->
    <xsl:template match="*[contains(@class, ' topic/entry ')]">
        <xsl:param name="prmRowAttr" required="yes" as="element()"/>
        <xsl:param name="prmColSpec" required="yes" as="element()*"/>
        <xsl:param name="prmRowHeight" required="yes" as="xs:double"/>
    
        <xsl:variable name="entryAttr" select="ahf:addEntryAttr(.,$prmRowAttr)" as="element()"/>
        <xsl:variable name="colname" select="string($entryAttr/@colname)"/>
        <xsl:variable name="atsName" select="if (ancestor::*[contains(@class,' topic/thead ')]) then 'atsTableHeaderCell' else 'atsTableBodyCell'"/>
        <fo:table-cell>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="$atsName"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getColSpecAttr($colname,$prmColSpec)"/>
            <xsl:copy-of select="ahf:getEntryAttr(.,$entryAttr,$prmColSpec)"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:choose>
                <xsl:when test="string(@rotate) eq '1'">
                    <fo:block-container>
                        <xsl:call-template name="getAttributeSet">
                            <xsl:with-param name="prmAttrSetName" select="'atsRotatedEntry'"/>
                        </xsl:call-template>
                        <xsl:attribute name="width" select="concat(string($prmRowHeight),'em')"/>
                        <fo:block>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:block-container>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block>
                        <xsl:apply-templates/>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:table-cell>
    </xsl:template>
    
    <!-- 
     function:	build entry attributes
     param:		prmEntry, prmRowAttr
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:addEntryAttr" as="element()">
        <xsl:param name="prmEntry"    as="element()"/>
        <xsl:param name="prmRowAttr"  as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmRowAttr/@*"/>
            <xsl:copy-of select="$prmEntry/@colname"/>
            <xsl:copy-of select="$prmEntry/@namest"/>
            <xsl:copy-of select="$prmEntry/@nameend"/>
            <xsl:copy-of select="$prmEntry/@morerows"/>
            <xsl:copy-of select="$prmEntry/@colsep"/>
            <xsl:copy-of select="$prmEntry/@rowsep"/>
            <xsl:copy-of select="$prmEntry/@align"/>
            <xsl:copy-of select="$prmEntry/@char"/>
            <xsl:copy-of select="$prmEntry/@valign"/>
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	get XSL-FO property from CALS table entry attributes
     param:		prmEntry, prmEntryAttr, prmColSpec
     return:	attribute()*
     note:		DITA-OT 1.5 sets correct @colname to every entry element.
                This stylesheet use this functionality.
     -->
    <xsl:function name="ahf:getEntryAttr" as="attribute()*">
        <xsl:param name="prmEntry"        as="element()"/>
        <xsl:param name="prmEntryAttr"    as="element()"/>
        <xsl:param name="prmColSpec"      as="element()*"/>
        
        <xsl:variable name="colname" select="string($prmEntryAttr/@colname)"/>
        
        <!-- colsep -->
        <xsl:choose>
            <xsl:when test="string($prmEntryAttr/@colsep) eq '0'">
                <xsl:attribute name="border-end-style" select="'none'"/>
            </xsl:when>
            <xsl:when test="string($prmEntryAttr/@colsep) eq '1'">
                <xsl:attribute name="border-end-style" select="'solid'"/>
            </xsl:when>
        </xsl:choose>
        
        <!-- rowsep -->
        <xsl:choose>
            <xsl:when test="string($prmEntryAttr/@rowsep) eq '0'">
                <xsl:attribute name="border-after-style" select="'none'"/>
            </xsl:when>
            <xsl:when test="string($prmEntryAttr/@rowsep) eq '1'">
                <xsl:attribute name="border-after-style" select="'solid'"/>
            </xsl:when>
        </xsl:choose>
        
        <!-- rowheader -->
        <xsl:if test="(string($prmEntryAttr/@rowheader) eq 'firstcol') and ($colname='col1')">
            <xsl:sequence select="ahf:getAttributeSet('atsHeaderRow')"/>
        </xsl:if>
        
        <!-- align -->
        <xsl:if test="exists($prmEntryAttr/@align)">
            <xsl:variable name="align" as="xs:string" select="string($prmEntryAttr/@align)"/>
            <!--xsl:message select="'align=',$align"/-->
            <xsl:choose>
                <xsl:when test="$align eq 'char'">
                    <xsl:variable name="char" select="string($prmEntryAttr/@char)"/>
                    <!--xsl:variable name="charoff" select="string($prmEntryAttr/@charoff)"/-->
                    <xsl:choose>
                        <xsl:when test="string($char)">
                            <xsl:attribute name="text-align" select="$char"/>
                            <!--xsl:if test="string($charoff)">
                                <xsl:attribute name="start-indent" select="concat($charoff,'%')"/>
                            </xsl:if-->
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="text-align" select="$align"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        
        <!-- valign -->
        <xsl:if test="exists($prmEntryAttr/@valign)">
            <xsl:variable name="valign" as="xs:string" select="string($prmEntryAttr/@valign)"/>
            <xsl:choose>
                <xsl:when test="$valign eq 'top'">
                    <xsl:attribute name="display-align" select="'before'"/>
                </xsl:when>
                <xsl:when test="$valign eq 'bottom'">
                    <xsl:attribute name="display-align" select="'after'"/>
                </xsl:when>
                <xsl:when test="$valign eq 'middle'">
                    <xsl:attribute name="display-align" select="'center'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        
        <!-- namest,nameend -->
        <xsl:if test="exists($prmEntryAttr/@namest) and exists($prmEntryAttr/@nameend)">
            <xsl:variable name="startpos" as="xs:integer" select="xs:integer(string($prmColSpec[string(@ahf:column-name) eq string($prmEntryAttr/@namest)]/@column-number))"/>
            <xsl:variable name="endpos"   as="xs:integer" select="xs:integer(string($prmColSpec[string(@ahf:column-name) eq string($prmEntryAttr/@nameend)]/@column-number))"/>
            <xsl:variable name="spancolumns" as="xs:integer" select="$endpos - $startpos + 1"/>
            <xsl:attribute name="number-columns-spanned" select="string($spancolumns)"/>
        </xsl:if>
    
        <!-- morerows -->
        <xsl:if test="exists($prmEntryAttr/@morerows)">
            <xsl:attribute name="number-rows-spanned" select="string(xs:integer($prmEntryAttr/@morerows) + 1)"/>
        </xsl:if>
        
    </xsl:function>
    
    <!-- 
     function:	inherit colspec property to table entry
     param:		prmColName, prmColSpec
     return:	attribute()*
     note:		DITA-OT 1.5 sets correct @colname to every entry element.
                This stylesheet use this functionality.
     -->
    <xsl:function name="ahf:getColSpecAttr" as="attribute()*">
        <xsl:param name="prmColName"  as="xs:string"/>
        <xsl:param name="prmColSpec"  as="element()*"/>
    
        <xsl:variable name="colSpec" select="$prmColSpec[@ahf:column-name=$prmColName][1]"/>
        
        <xsl:if test="exists($colSpec)">
            <xsl:if test="exists($colSpec/@border-end-style)">
                <xsl:attribute name="border-end-style" select="'from-table-column()'"/>
            </xsl:if>
        
            <xsl:if test="exists($colSpec/@border-after-style)">
                <xsl:attribute name="border-after-style" select="'from-table-column()'"/>
            </xsl:if>
        
            <xsl:if test="exists($colSpec/@text-align)">
                <xsl:attribute name="text-align" select="'from-table-column()'"/>
            </xsl:if>
    
            <!-- Does not support charoff -->
            <!--xsl:if test="exists($colSpec/@start-indent)">
                <xsl:attribute name="start-indent" select="'from-table-column()'"/>
            </xsl:if-->
        </xsl:if>
    </xsl:function>
    
    
    <!-- **************************** 
            Simple Table Templates
         ****************************-->
    <!-- 
     function:	simpletable template
     param:	    
     return:	fo:table
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/simpletable ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsSimpleTable'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/simpletable ')]">
        <xsl:variable name="keyCol" select="ahf:getKeyCol(.)" as="xs:integer"/>
        <xsl:variable name="simpleTableAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:table-and-caption>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)[name() eq 'text-align']"/>
            <fo:table>
                <xsl:copy-of select="$simpleTableAttr"/>
                <xsl:copy-of select="ahf:getDisplayAtts(.,$simpleTableAttr)"/>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty(.)[name() ne 'text-align']"/>
                <xsl:if test="exists(@relcolwidth)">
                    <xsl:copy-of select="ahf:getAttributeSet('atsSimpleTableFixed')"/>
                    <xsl:call-template name="processRelColWidth">
                        <xsl:with-param name="prmRelColWidth" select="string(@relcolwidth)"/>
                        <xsl:with-param name="prmTable" select="."/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates select="*[contains(@class,' topic/sthead ')]">
                    <xsl:with-param name="prmKeyCol"   select="$keyCol"/>
                </xsl:apply-templates>
                <fo:table-body>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsSimpleTableBody'"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="*[contains(@class,' topic/strow ')]">
                        <xsl:with-param name="prmKeyCol"   select="$keyCol"/>
                    </xsl:apply-templates>
                </fo:table-body>
            </fo:table>
        </fo:table-and-caption>
        <xsl:if test="not($pDisplayFnAtEndOfTopic)">
            <xsl:call-template name="makeFootNote">
                <xsl:with-param name="prmElement"  select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	sthead template
     param:	    prmKeyCol
     return:	fo:table-header
     note:		sthead is optional.
                This stylesheet apply bold for sthead if simpletable/@keycol is not defined.
     -->
    <xsl:template match="*[contains(@class, ' topic/sthead ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsSimpleTableHeader'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/sthead ')]">
        <xsl:param name="prmKeyCol"  required="yes" as="xs:integer"/>
        
        <fo:table-header>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:table-row>
                <xsl:call-template name="getAttributeSetWithLang">
                    <xsl:with-param name="prmAttrSetName" select="'atsSimpleTableRow'"/>
                </xsl:call-template>
                <xsl:apply-templates>
                    <xsl:with-param name="prmKeyCol"   select="$prmKeyCol"/>
                </xsl:apply-templates>
            </fo:table-row>
        </fo:table-header>
    </xsl:template>
    
    <!-- 
     function:	stentry template
     param:	    prmKeyCol
     return:	stentry contents (fo:table-cell)
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' topic/sthead ')]/*[contains(@class, ' topic/stentry ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsSimpleTableHeaderCell'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/sthead ')]/*[contains(@class, ' topic/stentry ')]">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
        <fo:table-cell>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:choose>
                <xsl:when test="$prmKeyCol = count(preceding-sibling::*[contains(@class, ' topic/stentry ')]) + 1">
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsPropertyTableKeyCol'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$prmKeyCol != 0">
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsPropertyTableNoKeyCol'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/strow ')]/*[contains(@class, ' topic/stentry ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsSimpleTableBodyCell'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/strow ')]/*[contains(@class, ' topic/stentry ')]">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
        <fo:table-cell>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:choose>
                <xsl:when test="$prmKeyCol = count(preceding-sibling::*[contains(@class, ' topic/stentry ')]) + 1">
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsPropertyTableKeyCol'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsPropertyTableNoKeyCol'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    
    
    <!-- 
     function:	strow template
     param:	    prmKeyCol
     return:	fo:table-row
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' topic/strow ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsSimpleTableRow'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class, ' topic/strow ')]">
        <xsl:param name="prmKeyCol"   required="yes"  as="xs:integer"/>
        <fo:table-row>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmKeyCol"   select="$prmKeyCol"/>
            </xsl:apply-templates>
        </fo:table-row>
    </xsl:template>
    
    
    <!-- *************************************** 
            Table related common templates
         ***************************************-->
    <!-- 
     function:	get @keycol value and return it.
     param:		prmTable
     return:	integer
     note:		
     -->
    <xsl:function name="ahf:getKeyCol" as="xs:integer">
        <xsl:param name="prmTable" as="element()"/>
        
        <xsl:variable name="keyCol" select="if ($prmTable/@keycol) then string($prmTable/@keycol) else '0'" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$keyCol castable as xs:integer">
                <xsl:choose>
                    <xsl:when test="xs:integer($keyCol) ge 0">
                        <xsl:sequence select="xs:integer($keyCol)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" 
                            select="ahf:replace($stMes050,('%file','%elem','%keycol'),(string($prmTable/@xtrf),name($prmTable),string($prmTable/@keycol)))"/>
                        </xsl:call-template>
                        <xsl:sequence select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                    select="ahf:replace($stMes050,('%file','%elem','%keycol'),(string($prmTable/@xtrf),name($prmTable),string($prmTable/@keycol)))"/>
                </xsl:call-template>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	@relcolwidth processing
     param:		prmRelColWidth, prmTable
     return:	fo:table-column
     note:		
     -->
    <xsl:template name="processRelColWidth">
        <xsl:param name="prmRelColWidth" required="yes" as="xs:string"/>
        <xsl:param name="prmTable"  required="yes" as="element()"/>
        
        <xsl:for-each select="tokenize(string($prmRelColWidth), '[\s]+')">
            <xsl:variable name="relColWidth"  select="string(.)"/>
            <xsl:variable name="relColNumber" select="position()"/>
            <fo:table-column>
                <xsl:attribute name="column-number">
                    <xsl:value-of select="$relColNumber"/>
                </xsl:attribute>
                <xsl:attribute name="column-width">
                    <!-- Get column width format string in XSL-FO -->
                    <xsl:call-template name="calc.column.width">
                        <xsl:with-param name="colwidth" select="$relColWidth"/>
                    </xsl:call-template>
                </xsl:attribute>
            </fo:table-column>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- 
     function:	Calculate column width template
     param:		colwidth
     return:	column width attribute value
     note:		This template is from W3C XSL specification.
     -->
    <xsl:template name="calc.column.width">
        <xsl:param name="colwidth">1*</xsl:param>
        <!-- Ok, the colwidth could have any one of the following forms: -->
        <!--        1*       = proportional width -->
        <!--     1unit       = 1.0 units wide -->
        <!--         1       = 1pt wide -->
        <!--  1*+1unit       = proportional width + some fixed width -->
        <!--      1*+1       = proportional width + some fixed width -->
        <!-- If it has a proportional width, translate it to XSL -->
        <xsl:if test="contains($colwidth, '*')">
          <!-- modified to handle "*" as input -->
          <xsl:variable name="colfactor">
            <xsl:value-of select="substring-before($colwidth, '*')"/>
          </xsl:variable>
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:choose>
            <xsl:when test="not($colfactor = '')">
              <xsl:value-of select="$colfactor"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
          <xsl:text>)</xsl:text>
        </xsl:if>
        <!-- Now get the non-proportional part of the specification -->
        <xsl:variable name="width-units">
          <xsl:choose>
            <xsl:when test="contains($colwidth, '*')">
              <xsl:value-of select="normalize-space(substring-after($colwidth, '*'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($colwidth)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Now the width-units could have any one of the following forms: -->
        <!--                 = <empty string> -->
        <!--     1unit       = 1.0 units wide -->
        <!--         1       = 1pt wide -->
        <!-- with an optional leading sign -->
        <!-- Get the width part by blanking out the units part and discarding -->
        <!-- white space. -->
        <xsl:variable name="width" select="normalize-space(translate($width-units,                           '+-0123456789.abcdefghijklmnopqrstuvwxyz',                           '+-0123456789.'))"/>
        <!-- Get the units part by blanking out the width part and discarding -->
        <!-- white space. -->
        <xsl:variable name="units" select="normalize-space(translate($width-units,                           'abcdefghijklmnopqrstuvwxyz+-0123456789.',                           'abcdefghijklmnopqrstuvwxyz'))"/>
        <!-- Output the width -->
        <xsl:value-of select="$width"/>
        <!-- Output the units, translated appropriately -->
        <xsl:choose>
          <xsl:when test="$units = 'pi'">pc</xsl:when>
          <xsl:when test="$units = '' and $width != ''">pt</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$units"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Generate table title prefix
     param:		prmTopicRef, prmTable
     return:	Table title prefix
     note:		
     -->
    <xsl:template name="ahf:getTableTitlePrefix" as="xs:string">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()"/>
        <xsl:param name="prmTable" required="no" as="element()" select="."/>
        
        <xsl:variable name="titlePrefix" as="xs:string">
            <xsl:choose>
                <xsl:when test="$pAddNumberingTitlePrefix">
                    <xsl:variable name="titlePrefixPart" select="ahf:genLevelTitlePrefixByCount($prmTopicRef,$cTableGroupingLevelMax)"/>
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
        
        <xsl:variable name="topicNode" select="$prmTable/ancestor::*[contains(@class, ' topic/topic ')][position()=last()]"/>
        
        <xsl:variable name="tablePreviousAmount" as="xs:integer">
            <xsl:variable name="topicNodeId" select="ahf:generateId($topicNode,$prmTopicRef)"/>
            <xsl:sequence select="$tableNumberingMap/*[string(@id) eq $topicNodeId]/@count"/>
        </xsl:variable>
        
        <xsl:variable name="tableCurrentAmount"  as="xs:integer">
            <xsl:variable name="topic" as="element()" select="$prmTable/ancestor::*[contains(@class,' topic/topic ')][last()]"/>
            <xsl:sequence select="count($topic//*[contains(@class,' topic/table ')][child::*[contains(@class, ' topic/title ')]][. &lt;&lt; $prmTable]|$prmTable)"/>
        </xsl:variable>
        
        <xsl:variable name="tableNumber" select="$tablePreviousAmount + $tableCurrentAmount" as="xs:integer"/>
        
        <xsl:sequence select="concat($cTableTitle,$titlePrefix,string($tableNumber))"/>
    </xsl:template>

    <xsl:function name="ahf:getTableTitlePrefix" as="xs:string">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmTable" as="element()"/>
        
        <xsl:call-template name="ahf:getTableTitlePrefix">
            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
            <xsl:with-param name="prmTable" select="$prmTable"/>
        </xsl:call-template>
    </xsl:function>

</xsl:stylesheet>