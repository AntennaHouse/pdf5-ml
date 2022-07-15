<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Merged file conversion templates
Copyright © 2009-2013 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!-- dita2fo_convmerged.xsl
         1. remove topicref/@print="no" and its descendant.
         2. remove topicgroup
         3. Handle flagging using dita2fo_flag_ditaval.xsl.
         4. Clone topic that is referenced from map multiple times.
     -->
    
    <!-- map or bookmap: Already defined in dita2fo_global.xsl -->
    <xsl:variable name="root"  as="element()" select="/*[1]"/>
    <xsl:variable name="map" as="element()" select="$root/*[contains(@class,' map/map ')][1]"/>
    
    <!-- All topiref-->
    <xsl:variable name="allTopicRefs" as="element()*" select="$map//*[contains(@class,' map/topicref ')][not(ancestor::*[contains(@class,' map/reltable ')])]"/>
    
    <!-- topicref that has @print="no"-->
    <xsl:variable name="noPrintTopicRefs" as="element()*" select="$allTopicRefs[ancestor-or-self::*[string(@print) eq 'no']]"/>
    
    <!-- Normal topicref -->
    <xsl:variable name="normalTopicRefs" as="element()*" select="$allTopicRefs except $noPrintTopicRefs"/>
    
    <!-- @href of noraml topicref -->
    <xsl:variable name="normalHrefs" as="xs:string*">
        <xsl:for-each select="$normalTopicRefs">
            <xsl:sequence select="string(@href)"/>
        </xsl:for-each>
    </xsl:variable>

    <!-- @href of topicref that has @print="no"-->
    <xsl:variable name="noPrintHrefs" as="xs:string*">
        <xsl:for-each select="$noPrintTopicRefs">
            <xsl:variable name="noPrintTopicRef" as="element()" select="."/>
            <xsl:variable name="href" as="xs:string" select="string($noPrintTopicRef/@href)"/>
            <xsl:if test="exists($href) and empty($normalHrefs[. eq $href])">
                <xsl:sequence select="$href"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- topic/@id that is pointed from topicref that has @print="no"-->
    <xsl:variable name="noPrintTopicIds" as="xs:string*">
        <xsl:for-each select="$noPrintHrefs">
            <xsl:sequence select="substring-after(.,'#')"/>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- Normal topic/@id -->
    <xsl:variable name="normalTopicIds" as="xs:string*">
        <xsl:for-each select="$normalHrefs">
            <xsl:sequence select="substring-after(.,'#')"/>
        </xsl:for-each>
    </xsl:variable>

    <!-- topicrefs that references same topic -->
    <xsl:variable name="duplicateTopicRefs" as="element()*">
        <xsl:for-each select="$normalTopicRefs[exists(@href)]">
            <xsl:variable name="topicRef" as="element()" select="."/>
            <xsl:variable name="href" as="xs:string" select="string(@href)"/>
            <xsl:if test="$normalTopicRefs[. &lt;&lt; $topicRef][exists(@href)][string(@href) eq $href][empty($noPrintTopicRefs[. is $topicRef])]">
                <xsl:sequence select="$topicRef"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- Duplicate topic/@id -->
    <xsl:variable name="duplicateTopicIds" as="xs:string*">
        <xsl:for-each select="$duplicateTopicRefs">
            <xsl:variable name="href" as="xs:string" select="substring-after(./@href,'#')"/>
            <xsl:sequence select="$href"/>
        </xsl:for-each>
    </xsl:variable>

    <!-- topic access key -->
    <xsl:key name="topicById"  match="/*//*[contains(@class, ' topic/topic')]" use="@id"/>

    <!-- 
     function:    root element template
     param:       none
     return:      copied result
     note:        Clone multiplly referenced topic using another topic/@id
     -->
    <xsl:template match="dita-merge">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="$map"/>
            <xsl:call-template name="outputTopic"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:    topic output template
     param:       none
     return:      copied result
     note:        Clone multiply referenced topic using another topic/@id
     -->
    <xsl:template name="outputTopic">
        <xsl:for-each select="$normalTopicIds">
            <xsl:variable name="topicId" as="xs:string" select="."/>
            <xsl:if test="string($topicId)">
                <xsl:variable name="position" as="xs:integer" select="position()"/>
                <xsl:variable name="topicref" as="element()" select="$normalTopicRefs[$position]"/>
                <xsl:variable name="prevTopicIds" as="xs:string*" select="subsequence($normalTopicIds,1,$position - 1)"/>
                <xsl:variable name="duplicateCount" as="xs:integer" select="count($prevTopicIds[. eq $topicId])"/>
                <xsl:variable name="topic" as="element()?" select="key('topicById',$topicId,$root)"/>
                <xsl:choose>
                    <xsl:when test="exists($topic)">
                        <xsl:apply-templates select="$topic">
                            <xsl:with-param name="prmTopicRefNo" tunnel="yes" select="$duplicateCount"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" select="ahf:replace($stMes1009,('%href','%xtrc'),(concat('#',$topicId),string($topicref/@xtrc)))"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:    General template for all element
     param:       none
     return:      copied result
     note:        Add @chage-bar-style if it exists.
                  Add .ditaval flagging style as @fo:prop
     -->
    <xsl:template match="*">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:param name="prmDitaValChangeBarStyle" tunnel="yes" required="no" select="''"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="string($prmDitaValChangeBarStyle)">
                <xsl:attribute name="change-bar-style" select="$prmDitaValChangeBarStyle"/>
            </xsl:if>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <xsl:apply-templates>
                <xsl:with-param name="prmDitaValFlagStyle" tunnel="yes" select="''"/>
                <xsl:with-param name="prmDitaValChangeBarStyle" tunnel="yes" select="''"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:    topicgroup
     param:       none
     return:      descendant element
     note:        An topicgroup is redundant for document structure.
                  It sometimes bothers counting the nesting level of topicref.
     -->
    <xsl:template match="*[contains(@class, ' mapgroup-d/topicgroup ')]" priority="5">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--
     function:    topicref
     param:       none
     return:      self and descendant element or none
     note:        if @print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')]" as="element()?">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:choose>
            <xsl:when test="string(@print) eq 'no'" >
                <xsl:for-each select="descendant-or-self::*[contains(@class,' map/topicref ')]">
                    <xsl:if test="exists(@href)">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" select="ahf:replace($stMes1001,('%href','%ohref'),(string(@href),string(@ohref)))"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="empty(ancestor::*[contains(@class,' map/reltable ')]) and $duplicateTopicRefs[. is $topicRef]">
                <xsl:variable name="href" as="xs:string" select="string(@href)"/>
                <xsl:variable name="duplicateCount" as="xs:integer" select="count($allTopicRefs[. &lt;&lt; $topicRef][string(@href) eq $href])"/>
                <xsl:copy>
                    <xsl:attribute name="href" select="if ($duplicateCount gt 0) then concat($href,'_',string($duplicateCount)) else $href"/>
                    <xsl:copy-of select="@* except @href"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:    Get topic from topicref 
     param:       prmTopicRef
     return:      element()?
     note:        
     -->
    <xsl:function name="ahf:getTopicFromTopicRef" as="element()?">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="id" select="substring-after($prmTopicRef/@href, '#')" as="xs:string"/>
        <xsl:variable name="topicContent" select="if (string($id)) then key('topicById', $id, $root)[1] else ()" as="element()?"/>
        <xsl:sequence select="$topicContent"/>
    </xsl:function>

    <!--
     function:    topic
     param:       prmDitaValFlagStyle, prmDitaValChangeBarStyle
     return:      self and descendant element or none
     note:        if @id is pointed from the topicref that has print="no", ignore it.
                  SPEC: If $prmTopicRefNo > 0,
                        change topic/@id according to referenced number.
                        2019-01-13 t.makita
     -->
    <xsl:template match="*[contains(@class,' topic/topic ')]">
        <xsl:param name="prmTopicRefNo" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:param name="prmDitaValChangeBarStyle" tunnel="yes" required="no" select="''"/>
        <xsl:variable name="id" as="xs:string" select="string(@id)"/>
        <xsl:copy>
            <xsl:attribute name="id" select="if ($prmTopicRefNo gt 0) then concat(string(@id),'_',string($prmTopicRefNo)) else string(@id)"/>
            <xsl:if test="exists(@oid)">
                <xsl:attribute name="oid" select="if ($prmTopicRefNo gt 0) then concat(string(@oid),'_',string($prmTopicRefNo)) else string(@oid)"/>
            </xsl:if>
            <xsl:copy-of select="@* except (@id | @oid)"/>
            <xsl:if test="string($prmDitaValChangeBarStyle)">
                <xsl:attribute name="change-bar-style" select="$prmDitaValChangeBarStyle"/>
            </xsl:if>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <xsl:apply-templates>
                <xsl:with-param name="prmDitaValFlagStyle" tunnel="yes" select="''"/>
                <xsl:with-param name="prmDitaValChangeBarStyle" tunnel="yes" select="''"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- template for topic/@id,@oid -->
    <xsl:template match="*[contains(@class,' topic/topic ')]/@id">
        <xsl:param name="prmTopicRefNo" required="yes" as="xs:integer"/>
        <xsl:variable name="id" as="xs:string" select="string(.)"/>
        <xsl:attribute name="id" select="if ($prmTopicRefNo gt 0) then concat($id,'_',string($prmTopicRefNo)) else $id"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/topic ')]/@oid">
        <xsl:param name="prmTopicRefNo" required="yes" as="xs:integer"/>
        <xsl:variable name="oid" as="xs:string" select="string(.)"/>
        <xsl:attribute name="oid" select="if ($prmTopicRefNo gt 0) then concat($oid,'_',string($prmTopicRefNo)) else $oid"/>
    </xsl:template>

    <!--
     function:    link
     param:       none
     return:      self and descendant element or none
     note:        if link@href points to the topicref that has print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' topic/link ')]">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:param name="prmDitaValChangeBarStyle" tunnel="yes" required="no" select="''"/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:choose>
            <xsl:when test="exists(index-of($noPrintHrefs,$href)) and empty(index-of($normalHrefs,$href))">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1003,('%href'),($href))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="string($prmDitaValChangeBarStyle)">
                        <xsl:attribute name="change-bar-style" select="$prmDitaValChangeBarStyle"/>
                    </xsl:if>
                    <xsl:if test="string($prmDitaValFlagStyle)">
                        <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
                    </xsl:if>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmDitaValFlagStyle" tunnel="yes" select="''"/>
                        <xsl:with-param name="prmDitaValChangeBarStyle" tunnel="yes" select="''"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
     function:     xref
     param:        none
     return:       self and descendant element or none
     note:         if xref@href points to the topic that has print="no", output warning message.
     -->
    <xsl:template match="*[contains(@class,' topic/xref ')][starts-with(string(@href),'#')]">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:param name="prmDitaValChangeBarStyle" tunnel="yes" required="no" select="''"/>
        <xsl:param name="prmTopicRefNo" required="no" tunnel="yes" as="xs:integer" select="0"/>
        <xsl:variable name="xref" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:variable name="isLocalHref" as="xs:boolean" select="starts-with($href,'#')"/>
        <xsl:variable name="refTopicHref" as="xs:string">
            <xsl:choose>
                <xsl:when test="$isLocalHref">
                    <xsl:choose>
                        <xsl:when test="contains($href,'/')">
                            <xsl:sequence select="substring-before($href,'/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="string($refTopicHref) and exists(index-of($noPrintHrefs,$refTopicHref)) and empty(index-of($normalHrefs,$refTopicHref))" >
            <xsl:call-template name="warningContinue">
                <xsl:with-param name="prmMes" select="ahf:replace($stMes1004,('%href'),($href))"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:variable name="refTopicId" as="xs:string" select="substring-after($refTopicHref,'#')"/>
        <xsl:variable name="refElemId" as="xs:string" select="if (contains($href,'/')) then substring-after($href,'/') else ''"/>
        <xsl:variable name="topIds" as="xs:string*" select="for $id in $xref/ancestor::*[contains(@class,' topic/topic ')][last()]/descendant-or-self::*[contains(@class,' topic/topic ')]/@id return string($id)"/>
        <xsl:variable name="topicIdsExperimental">
            <xsl:choose>
                <!-- xref exists inside topic -->
                <xsl:when test="$xref/ancestor::*[contains(@class,' topic/topic ')]">
                    <xsl:sequence select="for $id in $xref/ancestor::*[contains(@class,' topic/topic ')][last()]/descendant-or-self::*[contains(@class,' topic/topic ')]/@id return string($id)"/>
                </xsl:when>
                <!-- xref exists inside topicref/topicmeta/navtitle
                     In this case DITA-OT 3.3 does not maintain the topic destination portion of xref/@href
                 -->
                <xsl:when test="$xref/ancestor::*[contains(@class,' map/topicmeta ')]/ancestor::*[contains(@class,' map/topicref ')][@href]">
                    <xsl:variable name="href" as="xs:string" select="$xref/ancestor::*[contains(@class,' map/topicmeta ')]/ancestor::*[contains(@class,' map/topicref ')]/@href/string(.)"/>
                    <xsl:variable name="topicId" as="xs:string" select="substring-after($href,'#')"/>
                    <xsl:sequence select="$topicId"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable> 

        <xsl:copy>
            <xsl:choose>
                <xsl:when test="exists($topIds[. eq $refTopicId])">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="string($refElemId)">
                                <xsl:choose>
                                    <xsl:when test="$prmTopicRefNo gt 0">
                                        <xsl:sequence select="concat($refTopicHref,'_',string($prmTopicRefNo),'/',$refElemId)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="concat($refTopicHref,'/',$refElemId)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="$prmTopicRefNo gt 0">
                                        <xsl:sequence select="concat($refTopicHref,'_',string($prmTopicRefNo))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="$refTopicHref"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@href"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="@* except @href"/>
            <xsl:if test="string($prmDitaValChangeBarStyle)">
                <xsl:attribute name="change-bar-style" select="$prmDitaValChangeBarStyle"/>
            </xsl:if>
            <xsl:if test="string($prmDitaValFlagStyle)">
                <xsl:copy-of select="ahf:getMergedDitaValFlagStyleAttr(.,$prmDitaValFlagStyle)"/>
            </xsl:if>
            <xsl:apply-templates>
                <xsl:with-param name="prmDitaValFlagStyle" tunnel="yes" select="''"/>
                <xsl:with-param name="prmDitaValChangeBarStyle" tunnel="yes" select="''"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/xref ')]/@href">
        <xsl:param name="prmNewXrefHref" required="no" as="xs:string" select="''"/>
        <xsl:choose>
            <xsl:when test="string($prmNewXrefHref)">
                <xsl:attribute name="href" select="$prmNewXrefHref"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:     empty strow template
     param:        none
     return:       empty
     note:         DITA DTD allows empty strow, but it is redundant.
     -->
    <xsl:template match="*[contains(@class,' topic/strow ')][empty(*[contains(@class,' topic/stentry ')])]"/>
    
    <!-- 
     function:     comment template
     param:        none
     return:       comment 
     note:         none
     -->
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    
    <!-- 
     function:     processing-instruction template
     param:        none
     return:       processing-instruction
     note:        
     -->
    <xsl:template match="processing-instruction()">
        <xsl:copy/>
    </xsl:template>

    <!-- 
     function:    required-cleanup template
     param:       none
     return:      none or itself 
     note:        If not output required-cleanup, remove it at this template.
     -->
    <xsl:template match="*[contains(@class,' topic/required-cleanup ')][not($pOutputRequiredCleanup)]"/>
    
    <!-- 
     function:    draft-comment template
     param:       none
     return:      none or itself 
     note:        If not output draft-comment, remove it at this template.
     -->
    <xsl:template match="*[contains(@class,' topic/draft-comment ')][not($pOutputDraftComment)]"/>

    <!-- 
     function:    Check $prmAttr has $prmValue
     param:       prmAttr, prmValue
     return:      xs:boolean 
     note:        Return true() if $prmAttr attribute has $prmValue
     -->
    <xsl:function name="ahf:HasAttr" as="xs:boolean">
        <xsl:param name="prmAttr" as="attribute()?"/>
        <xsl:param name="prmValue" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="empty($prmAttr)">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="attr" as="xs:string" select="string($prmAttr)"/>
                <xsl:variable name="attVals" as="xs:string*" select="tokenize($attr,'[\s]+')"/>
                <xsl:sequence select="$prmValue = $attVals"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
