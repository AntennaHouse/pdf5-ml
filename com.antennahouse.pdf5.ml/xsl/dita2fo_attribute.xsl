<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Common attribute templates
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
     function:	Process %univ-atts; attribute
     param:		prmElement, prmTopicRef,prmNeedId
     return:	attribute node
     note:		Added @clear attribute processing.
                2016/07/17 t.makita
     -->
    <xsl:function name="ahf:getUnivAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:param name="prmTopicRef" as="element()?"/>
        <xsl:param name="prmNeedId"   as="xs:boolean"/>
    
        <xsl:call-template name="ahf:getUnivAtts">
            <xsl:with-param name="prmElement" select="$prmElement"/>
            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
            <xsl:with-param name="prmNeedId"   tunnel="yes" select="$prmNeedId"/>
        </xsl:call-template>
        
    </xsl:function>

    <xsl:template name="ahf:getUnivAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()" required="no" select="."/>
        <xsl:param name="prmTopicRef" as="element()?" tunnel="yes" required="yes"/>
        <xsl:param name="prmNeedId"   as="xs:boolean" tunnel="yes" required="no" select="true()"/>
        
        <!-- localization-atts -->
        <xsl:call-template name="ahf:getLocalizationAtts">
            <xsl:with-param name="prmElement" select="$prmElement"/>
        </xsl:call-template>
        
        <!-- id-atts -->
        <xsl:call-template name="ahf:getIdAtts">
            <xsl:with-param name="prmElement" select="$prmElement"/>
            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
            <xsl:with-param name="prmNeedId" tunnel="yes" select="$prmNeedId"/>
        </xsl:call-template>
        
        <!-- Clear attribute -->
        <xsl:copy-of select="$prmElement/@clear"/>
        
    </xsl:template>
    

    <!-- 
     function:	Process %id-atts; attribute
     param:		prmElement, prmTopicRef, prmNeedId
     return:	attribute node
     note:		Use template version for normal context such as topic/body/p.
                In most cases we can omit paramters.
                <xsl:call-template name="ahf:getIdAtts"/>
                Use function version for the special context such as generateing id for title.
                We can explicitly specify parameters for this case.
     -->
    <xsl:function name="ahf:getIdAtts" as="attribute()*">
        <xsl:param name="prmElement"  as="element()"/>
        <xsl:param name="prmTopicRef" as="element()?"/>
        <xsl:param name="prmNeedId"   as="xs:boolean"/>
    
        <xsl:call-template name="ahf:getIdAtts">
            <xsl:with-param name="prmElement" select="$prmElement"/>
            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
            <xsl:with-param name="prmNeedId"   tunnel="yes" select="$prmNeedId"/>
        </xsl:call-template>
    
    </xsl:function>

    <xsl:template name="ahf:getIdAtts" as="attribute()*">
        <xsl:param name="prmElement"  as="element()" required="no" select="."/>
        <xsl:param name="prmTopicRef" as="element()?" tunnel="yes" required="yes"/>
        <xsl:param name="prmNeedId"   as="xs:boolean" tunnel="yes" required="no" select="true()"/>
        
        <xsl:choose>
            <!-- topicref -->
            <xsl:when test="contains($prmElement/@class, ' map/topicref ') and $prmNeedId">
                <xsl:choose>
                    <xsl:when test="$prmElement/@id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="$prmElement/@id"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="id">
                            <xsl:value-of select="ahf:generateId($prmElement,())"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- id-atts: id -->
            <xsl:when test="($prmElement/@id) and $prmNeedId">
                <xsl:variable name="id" select="$prmElement/@id" as="attribute()"/>
                <!-- topicRefCount: Count of topicref that refers this topic -->
                <xsl:variable name="topicRefCount" as="xs:integer" select="if (exists($prmTopicRef)) then ahf:countTopicRef($prmTopicRef) else 1"/>
                <xsl:choose>
                    <xsl:when test="contains($prmElement/@class, ' topic/topic ')">
                        <!-- Topic 
                         -->
                        <xsl:choose>
                            <xsl:when test="$pUseOid">
                                <!-- Adopt "oid". -->
                                <xsl:variable name="oid" select="$prmElement/@oid"/>
                                <!--xsl:variable name="oidKeyCount" select="count(key('elementByOid', $oid, $root))"/>
                                <xsl:variable name="oidSeq" select="if ($oidKeyCount=0) then 0 else count($prmElement/preceding::*[string(@oid)=string($oid)])"/-->
                                <!--xsl:variable name="refedTopic"  select="substring-after($prmTopicRef/@href, '#')=string($id)"/-->
                                <xsl:choose>
                                    <xsl:when test="$topicRefCount eq 1">
                                        <!-- normal pattern -->
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="$oid"/>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- topic is referenced more than once -->
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="$oid"/>
                                            <xsl:value-of select="$idSeparator"/>
                                            <xsl:value-of select="string($topicRefCount)"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!--xsl:if test="$refedTopic"-->
                                <!-- Add named destination -->
                                <xsl:attribute name="axf:destination-type" select="'xyz-top'"/>
                                <!--/xsl:if-->
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Adopt DITA-OT's id:"uniqueN" -->
                                <xsl:choose>
                                    <xsl:when test="$topicRefCount eq 1">
                                        <!-- normal pattern -->
                                        <xsl:sequence select="$id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- topic is referenced more than once -->
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="$id"/>
                                            <xsl:value-of select="$idSeparator"/>
                                            <xsl:value-of select="string($topicRefCount)"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Other local elements 
                             The id attribute must be unique only within the topic.
                             This stylesheet make them unique in whole document.
                             
                             "Note: Thus, within a single XML document containing multiple peer or nested topics, the
                              IDs of the non-topic elements only need to be unique within each topic without regard 
                              to the IDs of elements within any ancestor or descendant topics."
                              http://docs.oasis-open.org/dita/v1.2/cs01/spec/archSpec/id.html
                              
                              * However the parser does not report error when duplicate id exist in one topic.
                             
                        -->
                        <xsl:variable name="parentTopic" select="$prmElement/ancestor::*[contains(@class, ' topic/topic ')][1]" as="element()?"/>
                        <xsl:variable name="idCount" as="xs:integer">
                            <xsl:choose>
                                <xsl:when test="exists($parentTopic)">
                                    <xsl:number select="$prmElement" level="any" count="*[string(@id) eq string($id)]" from="*[contains(@class,' topic/topic ')]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="1"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$pUseOid">
                                <!-- add topic/oid to every id as prefix to make it unique -->
                                <xsl:variable name="topicOid" 
                                    select="string($prmElement/ancestor::*[contains(@class, ' topic/topic ')][1]/@oid)" as="xs:string"/>
                                <xsl:choose>
                                    <xsl:when test="$topicRefCount eq 1">
                                        <!-- normal pattern -->
                                        <xsl:attribute name="id">
                                            <xsl:if test="string($topicOid)">
                                                <xsl:value-of select="$topicOid"/>
                                                <xsl:value-of select="$idSeparator"/>
                                            </xsl:if>
                                            <xsl:value-of select="$id"/>
                                            <xsl:if test="$idCount gt 1">
                                                <xsl:value-of select="$idSeparator"/>
                                                <xsl:value-of select="string($idCount)"/>
                                            </xsl:if>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- topic is referenced more than once -->
                                        <xsl:attribute name="id">
                                            <xsl:if test="string($topicOid)">
                                                <xsl:value-of select="$topicOid"/>
                                                <xsl:value-of select="$idSeparator"/>
                                            </xsl:if>
                                            <xsl:value-of select="$id"/>
                                            <xsl:value-of select="$idSeparator"/>
                                            <xsl:value-of select="string($topicRefCount)"/>
                                            <xsl:value-of select="$idSeparator"/>
                                            <xsl:value-of select="string($idCount)"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="topicId" 
                                    select="string($prmElement/ancestor::*[contains(@class, ' topic/topic ')][1]/@id)" as="xs:string"/>
                                <xsl:choose>
                                    <xsl:when test="$topicRefCount eq 1">
                                        <!-- normal pattern -->
                                        <xsl:attribute name="id">
                                            <xsl:if test="string($topicId)">
                                                <xsl:value-of select="$topicId"/>
                                                <xsl:value-of select="$idSeparator"/>
                                            </xsl:if>
                                            <xsl:value-of select="$id"/>
                                            <xsl:if test="$idCount gt 1">
                                                <xsl:value-of select="$idSeparator"/>
                                                <xsl:value-of select="string($idCount)"/>
                                            </xsl:if>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- topic is referenced more than once -->
                                        <xsl:attribute name="id">
                                            <xsl:if test="string($topicId)">
                                                <xsl:value-of select="$topicId"/>
                                                <xsl:value-of select="$idSeparator"/>
                                            </xsl:if>
                                            <xsl:value-of select="$id"/>
                                            <xsl:value-of select="$idSeparator"/>
                                            <xsl:value-of select="string($topicRefCount)"/>
                                            <xsl:value-of select="$idSeparator"/>
                                            <xsl:value-of select="string($idCount)"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    

    <!-- 
     function:	Process %localization-atts; attribute
     param:		prmElement
     return:	attribute node
     note:		@dir="lro", "rlo" is not implemented.
     -->
    <xsl:function name="ahf:getLocalizationAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()"/>
    
        <!-- localization-atts: xml:lang -->
        <xsl:copy-of select="$prmElement/@xml:lang"/>
        
        <!-- localization-atts: dir
             Moved to dita2fo_dir_attribute.xsl
         -->
        <!--xsl:if test="$prmElement/@dir">
            <xsl:variable name="dir" select="$prmElement/@dir"/>
            <xsl:choose>
                <xsl:when test="($dir='ltr') or ($dir='rtl')">
                    <xsl:attribute name="direction" select="$dir"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:if-->
    </xsl:function>

    <xsl:template name="ahf:getLocalizationAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()" required="no" select="."/>
        
        <!-- localization-atts: xml:lang -->
        <xsl:copy-of select="$prmElement/@xml:lang"/>
    </xsl:template>
    

    <!-- 
     function:	Process %display-atts; attribute
     param:		prmElement, prmStyleName
     return:	attribute node
     note:		
     -->
    <xsl:function name="ahf:getDisplayAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:param name="prmStyleAttrs" as="attribute()*"/>
    
        <!-- @scale -->
        <xsl:sequence select="ahf:getScaleAtts($prmElement, $prmStyleAttrs)"/>
        
        <!-- @frame -->
        <xsl:sequence select="ahf:getFrameAtts($prmElement, $prmStyleAttrs)"/>
        
        <!-- @expanse -->
        <xsl:sequence select="ahf:getExpanseAtts($prmElement)"/>
    
    </xsl:function>
    
    <!-- 
     function:	Process scale attribute
     param:		prmElement, prmStyleAttrs
     return:	attribute node
     note:		
     -->
    <xsl:function name="ahf:getScaleAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:param name="prmStyleAttrs" as="attribute()*"/>
    
        <xsl:if test="exists($prmElement/@scale) and (string($prmElement/@scale) ne '100')">
            <xsl:variable name="scale" select="ahf:percentToNumber($prmElement/@scale,$prmElement)" as="xs:double"/>
            <xsl:variable name="fontSize" select="string($prmStyleAttrs[name() eq 'font-size'][last()])" as="xs:string"/>
            <xsl:choose>
                <xsl:when test="string($fontSize) and (string($fontSize) ne 'inherit')">
                    <xsl:variable name="fontSizeNu" select="ahf:getPropertyNu($fontSize)" as="xs:double"/>
                    <xsl:variable name="fontSizeUnit" select="ahf:getPropertyUnit($fontSize)" as="xs:string"/>
                    <xsl:variable name="fontSizeScaled" select="$fontSizeNu * $scale" as="xs:double"/>
                    <xsl:attribute name="font-size" select="concat(string($fontSizeScaled), $fontSizeUnit)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="font-size">
                        <xsl:text>inherited-property-value(font-size) * </xsl:text>
                        <xsl:value-of select="string($scale)"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    <!-- 
     function:	Process frame attribute
     param:		prmElement
     return:	attribute node
     note:		Added codes to adjust start-indent and end-indent considering frame width and original padding.
                2014-01-17 t.makita
     -->
    <xsl:function name="ahf:getFrameAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:param name="prmStyleAttrs" as="attribute()*"/>
        
        <xsl:if test="$prmElement/@frame">
            <xsl:variable name="frame" as="xs:string" select="string($prmElement/@frame)"/>
            
            <xsl:choose>
                <xsl:when test="contains($prmElement/@class, ' topic/simpletable ')
                             or contains($prmElement/@class, ' topic/table ')">
                    <xsl:choose>
                        <xsl:when test="$frame eq 'top'">
                            <xsl:call-template name="getAttributeSet">
                                <xsl:with-param name="prmAttrSetName" select="'atsTableBorderTop'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$frame eq 'bottom'">
                            <xsl:call-template name="getAttributeSet">
                                <xsl:with-param name="prmAttrSetName" select="'atsTableBorderBottom'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$frame eq 'topbot'">
                            <xsl:call-template name="getAttributeSet">
                                <xsl:with-param name="prmAttrSetName" select="'atsTableBorderTopBottom'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$frame eq 'all'">
                            <xsl:call-template name="getAttributeSet">
                                <xsl:with-param name="prmAttrSetName" select="'atsTableBorderAll'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$frame eq 'sides'">
                            <xsl:call-template name="getAttributeSet">
                                <xsl:with-param name="prmAttrSetName" select="'atsTableBorderSides'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$frame eq 'none'">
                            <xsl:call-template name="getAttributeSet">
                                <xsl:with-param name="prmAttrSetName" select="'atsTableBorderNone'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="originStyle" as="attribute()*" select="$prmStyleAttrs"/>
                    <xsl:variable name="borderStyle" as="attribute()*">
                        <xsl:choose>
                            <xsl:when test="$frame eq 'top'">
                                <xsl:call-template name="getAttributeSet">
                                    <xsl:with-param name="prmAttrSetName" select="'atsBlockBorderTop'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$frame eq 'bottom'">
                                <xsl:call-template name="getAttributeSet">
                                    <xsl:with-param name="prmAttrSetName" select="'atsBlockBorderBottom'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$frame eq 'topbot'">
                                <xsl:call-template name="getAttributeSet">
                                    <xsl:with-param name="prmAttrSetName" select="'atsBlockBorderTopBottom'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$frame eq 'all'">
                                <xsl:call-template name="getAttributeSet">
                                    <xsl:with-param name="prmAttrSetName" select="'atsBlockBorderAll'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$frame eq 'sides'">
                                <xsl:call-template name="getAttributeSet">
                                    <xsl:with-param name="prmAttrSetName" select="'atsBlockBorderSides'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$frame eq 'none'">
                                <xsl:call-template name="getAttributeSet">
                                    <xsl:with-param name="prmAttrSetName" select="'atsBlockBorderNone'"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="originStartIndent" as="attribute()?" select="$originStyle[name() eq 'start-indent']"/>
                    <xsl:variable name="originEndIndent" as="attribute()?" select="$originStyle[name() eq 'end-indent']"/>
                    <xsl:variable name="borderStartPadding" as="attribute()?" select="$borderStyle[name() = ('padding','padding-left','padding-start')][last()]"/>
                    <xsl:variable name="borderEndPadding" as="attribute()?" select="$borderStyle[name() = ('padding','padding-right','padding-end')][last()]"/>
                    <xsl:variable name="borderStartWidth" as="xs:string" select="substring-before(normalize-space(string($borderStyle[name() eq 'border-left'][last()])),' ')"/>
                    <xsl:variable name="borderEndWidth" as="xs:string" select="substring-before(normalize-space(string($borderStyle[name() eq 'border-right'][last()])),' ')"/>
                    <xsl:variable name="originStartPadding" as="attribute()?" select="$originStyle[name() = ('padding','padding-left','padding-start')][last()]"/>
                    <xsl:variable name="originEndPadding" as="attribute()?" select="$originStyle[name() = ('padding','padding-right','padding-end')][last()]"/>
                    <xsl:variable name="originPadding" as="attribute()*" select="$originStyle[matches(name(),'padding(-.+)?')]"/>
                    <xsl:variable name="adjustedIndent" as="attribute()*">
                        <!-- Adjust start-indent -->
                        <xsl:choose>
                            <xsl:when test="exists($originStartIndent) and exists($originStartPadding)">
                                <xsl:attribute name="start-indent">
                                    <xsl:value-of select="$originStartIndent"/>
                                    <xsl:text> + (</xsl:text>
                                    <xsl:value-of select="$borderStartWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="exists($originStartIndent) and exists($borderStartPadding)">
                                <xsl:attribute name="start-indent">
                                    <xsl:value-of select="$originStartIndent"/>
                                    <xsl:text> + (</xsl:text>
                                    <xsl:value-of select="$borderStartPadding"/>
                                    <xsl:text>) + (</xsl:text>
                                    <xsl:value-of select="$borderStartWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="exists($originStartIndent) and empty($borderStartPadding)">
                                <xsl:attribute name="start-indent">
                                    <xsl:value-of select="$originStartIndent"/>
                                    <xsl:text> + (</xsl:text>
                                    <xsl:value-of select="$borderStartWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="empty($originStartIndent) and exists($borderStartPadding)">
                                <xsl:attribute name="start-indent">
                                    <xsl:text>inherited-property-value(start-indent) + (</xsl:text>
                                    <xsl:value-of select="$borderStartPadding"/>
                                    <xsl:text>) + (</xsl:text>
                                    <xsl:value-of select="$borderStartWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="empty($originStartIndent) and empty($borderStartPadding)">
                                <xsl:attribute name="start-indent">
                                    <xsl:text>inherited-property-value(start-indent) + (</xsl:text>
                                    <xsl:value-of select="$borderStartWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <!-- Adjust end-indent -->
                        <xsl:choose>
                            <xsl:when test="exists($originEndIndent) and exists($originEndPadding)">
                                <xsl:attribute name="end-indent">
                                    <xsl:value-of select="$originEndIndent"/>
                                    <xsl:text> + (</xsl:text>
                                    <xsl:value-of select="$borderEndWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="exists($originEndIndent) and exists($borderEndPadding)">
                                <xsl:attribute name="end-indent">
                                    <xsl:value-of select="$originEndIndent"/>
                                    <xsl:text> + (</xsl:text>
                                    <xsl:value-of select="$borderEndPadding"/>
                                    <xsl:text>) + (</xsl:text>
                                    <xsl:value-of select="$borderEndWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="exists($originEndIndent) and empty($borderEndPadding)">
                                <xsl:attribute name="end-indent">
                                    <xsl:value-of select="$originEndIndent"/>
                                    <xsl:text> + (</xsl:text>
                                    <xsl:value-of select="$borderEndWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="empty($originEndIndent) and exists($borderEndPadding)">
                                <xsl:attribute name="end-indent">
                                    <xsl:text>inherited-property-value(end-indent) + (</xsl:text>
                                    <xsl:value-of select="$borderEndPadding"/>
                                    <xsl:text>) + (</xsl:text>
                                    <xsl:value-of select="$borderEndWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="empty($originEndIndent) and empty($borderEndPadding)">
                                <xsl:attribute name="end-indent">
                                    <xsl:text>inherited-property-value(end-indent) + (</xsl:text>
                                    <xsl:value-of select="$borderEndWidth"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:copy-of select="$borderStyle"/>
                    <xsl:copy-of select="$adjustedIndent"/>
                    <xsl:copy-of select="$originPadding"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    <!-- 
     function:	Process expanse/pgwide attribute
     param:		prmElement
     return:	attribute node
     note:		
     -->
    <xsl:function name="ahf:getExpanseAtts" as="attribute()*">
        <xsl:param name="prmElement" as="element()"/>
    
        <xsl:if test="exists($prmElement/@expanse)">
            <xsl:variable name="expanse" as="xs:string" select="string($prmElement/@expanse)"/>
            <xsl:if test="$expanse = ('page','column','spread')">
                <xsl:sequence select="ahf:getAttributeSet('atsExpanse')"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    
    <!-- 
     function:	Percent to number
     param:		prmPercent,prmElement
     return:	number
     note:		
     -->
    <xsl:function name="ahf:percentToNumber" as="xs:double">
        <xsl:param name="prmPercent" as="xs:string"/>
        <xsl:param name="prmElement" as="element()"/>
        
        <xsl:choose>
            <xsl:when test="string(number($prmPercent)) eq $NaN">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes028,('%scale','%elem','%file'),($prmPercent,name($prmElement),string($prmElement/@xtrf)))"/>
                </xsl:call-template>
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="number($prmPercent) div 100"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Generate unique id cosidering multiple topic reference
     param:		prmElement,prmTopicRef
     return:	id string
     note:		About the indexterm in topicref/topicmeta, the parameter 
                $prmTopicRef is empty.
     -->
    <xsl:function name="ahf:generateId" as="xs:string">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:param name="prmTopicRef" as="element()?"/>
        <xsl:call-template name="ahf:generateId">
            <xsl:with-param name="prmElement" select="$prmElement"/>
            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
        </xsl:call-template>
    </xsl:function>
    
    <xsl:template name="ahf:generateId" as="xs:string">
        <xsl:param name="prmElement" required="no" as="element()" select="."/>
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        
        <xsl:choose>
            <xsl:when test="$prmElement/ancestor::*[contains(@class,' map/map ')]">
                <xsl:sequence select="ahf:generateHistoryId($prmElement)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topicRefCount" select="if (exists($prmTopicRef)) then ahf:countTopicRef($prmTopicRef) else 0" as="xs:integer"/>
                <xsl:variable name="id1" select="ahf:generateHistoryId($prmElement)" as="xs:string"/>
                <xsl:variable name="id2" select="if ($topicRefCount &gt; 1) then $idSeparator else ''" as="xs:string"/>
                <xsl:variable name="id3" select="if ($topicRefCount &gt; 1) then string($topicRefCount) else ''" as="xs:string"/>
                <xsl:sequence select="concat($id1,$id2,$id3)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="ahf:generateIdAttr" as="attribute()">
        <xsl:param name="prmElement" required="no" as="element()" select="."/>
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()?"/>
        <xsl:attribute name="id" select="ahf:generateId($prmElement,$prmTopicRef)"/>
    </xsl:template>
    
</xsl:stylesheet>
