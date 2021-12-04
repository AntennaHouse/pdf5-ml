<?xml version="1.0" encoding="UTF-8"?>
<!--
 psmi.xsl

 Interpret the Page Sequence Master Interleave formatting semantic described
 at http://www.CraneSoftwrights.com/resources/psmi for interleaving page
 geometries in XSLFO flows.

 $Id: psmi.xsl,v 1.6 2002/11/01 18:11:28 G. Ken Holman Exp $

This semantic, its stylesheet file, and the information contained herein is
provided on an "AS IS" basis and CRANE SOFTWRIGHTS LTD. DISCLAIMS
ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
ANY WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE
ANY RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS 
FOR A PARTICULAR PURPOSE.

 2009/07/15 Modified by t.makita Antenna House, Inc. 
 - Change encoding to UTF-8.
 - Change XSLT version from 1.0 to 2.0.
 - Remove some restrictions.

 2021/06/08 Modified by t.makita Antenna House, Inc.
 - Add @id to the last fo:page-sequence if specified with $PRM_LAST_PAGESEQ_ID.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
                xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
                xmlns:ahp="http://www.antennahouse.com/names/XSLT/Document/PageControl"
                exclude-result-prefixes="psmi ahp ahf"
                version="2.0">
  
  <!-- Parameter: Generate last fo:page-sequence/@id -->
  <xsl:param name="PRM_LAST_PAGESEQ_ID" as="xs:string" required="no" select="''"/>
  <xsl:variable name="gpLastPageSeqId" as="xs:string" select="$PRM_LAST_PAGESEQ_ID"/>
  <xsl:variable name="gpGenLastPageSeqId" as="xs:boolean" select="$gpLastPageSeqId ne ''"/>
  
  <!-- Parameter: Last fo:page-sequence minus offset -->
  <xsl:param name="PRM_LAST_PAGESEQ_OFFSET" as="xs:string" required="no" select="'0'"/>
  <xsl:variable name="gpLastPageSeqOffset" as="xs:integer">
    <xsl:choose>
      <xsl:when test="$PRM_LAST_PAGESEQ_OFFSET castable as xs:integer">
        <xsl:sequence select="xs:integer($PRM_LAST_PAGESEQ_OFFSET)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('[psmi_impl] $PRM_LAST_PAGESEQ_OFFSET is not castable as xs:integer. Treat it as zero. Specified=',$PRM_LAST_PAGESEQ_OFFSET)"/>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Set of fo:page-sequence, fo:flow[@flow-name="xsl-region-body"], psmi:page-sequence and next element of psmi:page-sequence
       They are the trigger to generate fo:page-sequence.
   -->
  <xsl:variable name="flowOrPsmiPageSeqOrNext" as="element()+" select="/descendant::fo:flow[@flow-name eq 'xsl-region-body'][exists(parent::*/psmi:page-sequence)]/*[1] | /descendant::fo:page-sequence[empty(descendant::psmi:page-sequence)] | /descendant::psmi:page-sequence | descendant::psmi:page-sequence/following-sibling::*[1][empty(self::psmi:page-sequence)]"/>
  <xsl:variable name="lastElemOfFlowOrPsmiPageSeqOrNext" as="element()" select="$flowOrPsmiPageSeqOrNext[last() - $gpLastPageSeqOffset]"/>
  
  <xsl:template match="/">
    <xsl:message select="concat('[psmi_impl] $PRM_LAST_PAGESEQ_ID=',$PRM_LAST_PAGESEQ_ID)"/>
    <xsl:message select="concat('[psmi_impl] $PRM_LAST_PAGESEQ_OFFSET=',$PRM_LAST_PAGESEQ_OFFSET)"/>
    <!--xsl:message select="'[psmi_impl] $PRM_LAST_PAGESEQ_OFFSET=',$lastElemOfFlowOrPsmiPageSeqOrNext"/-->
    <xsl:apply-templates/>
  </xsl:template>

  <!-- 
     function:  Return psmi:page-sequence is for cover 
     param:		  prmPsmiPageSeq
     return:	  xs:boolean
     note:		  Added 2015-08-26 t.makita
     -->
  <xsl:function name="ahf:isCover">
    <xsl:param name="prmPsmiPageSeq" as="element(psmi:page-sequence)"/>
    <xsl:sequence select="string($prmPsmiPageSeq/@ahp:cover) eq 'true'"/>
  </xsl:function>

  <xsl:function name="ahf:isNotCover">
    <xsl:param name="prmPsmiPageSeq" as="element(psmi:page-sequence)"/>
    <xsl:sequence select="not(ahf:isCover($prmPsmiPageSeq))"/>
  </xsl:function>
  
  <!-- 
     function:  Return that the element is first effective occurence in fo:page-sequence 
     param:		  prmElem
     return:	  xs:boolean
     note:		  Added 2015-08-26 t.makita
     -->
  <xsl:function name="ahf:isFirstNonPsmiPageSeqOrPsmiPageSeqWoCover">
    <xsl:param name="prmElem" as="element()"/>
    <xsl:choose>
      <xsl:when test="exists($prmElem/self::psmi:page-sequence[ahf:isCover(.)])">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="exists($prmElem/preceding-sibling::*[self::psmi:page-sequence[ahf:isNotCover(.)]])">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="exists($prmElem/preceding-sibling::*[not(self::psmi:page-sequence)])">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="true()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
    <!--==========================================================================
      Handle a sequence of pages, only if it has the expected psmi:page-sequence
      children in the flow.
    -->
    <xsl:template match="fo:page-sequence">
      <xsl:choose>
        <xsl:when test="fo:flow/psmi:page-sequence"><!--accommodate new semantic-->
          <!-- Remove this xsl:if restriction.
               If we only want to make fo:page-sequence from nested structure,
               this check is not needed. (t.makita)
            -->
          <!--xsl:if test="@force-page-count = 'even' or
                        @force-page-count = 'odd'">
            <xsl:message>
              <xsl:text>Unable to support a 'force-page-count=' </xsl:text>
              <xsl:text>value of: </xsl:text>
              <xsl:value-of select="@force-page-count"/>
            </xsl:message>
          </xsl:if-->
          <xsl:apply-templates select="fo:flow/*[1]" mode="psmi:do-flow-children"/>
        </xsl:when>
        <xsl:when test="descendant::psmi:*"><!--unexpected location for semantic-->
          <xsl:call-template name="psmi:preserve"/><!-- this will catch each-->
        </xsl:when>
        <xsl:otherwise><!--no need to do special processing; faster to just copy-->
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$gpGenLastPageSeqId and (. is $lastElemOfFlowOrPsmiPageSeqOrNext)">
              <xsl:attribute name="id" select="$gpLastPageSeqId"/>
            </xsl:if>
            <xsl:copy-of select="node()"/>
          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <!--==========================================================================
      Create a page sequence from the flow.
    -->
    
    <xsl:template match="*" mode="psmi:do-flow-children">
      <fo:page-sequence>
                                                    <!--page-sequence attributes-->
        <xsl:copy-of select="../../@*[not(name(.)='initial-page-number')]"/>
        <xsl:if test="$gpGenLastPageSeqId and (. is $lastElemOfFlowOrPsmiPageSeqOrNext)">
          <xsl:attribute name="id" select="$gpLastPageSeqId"/>
        </xsl:if>
        <xsl:if test="self::psmi:page-sequence">
          <xsl:copy-of select="@*[not(name(.)='initial-page-number')]"/>
          <!--xsl:copy-of select="@master-reference"/-->
          <!-- XSL1.1 needs more property -->
          <!--xsl:if test="@*[name(.)!='master-reference']">
            <xsl:message>
              <xsl:text>Only the 'master-reference=' attribute is </xsl:text>
              <xsl:text>allowed for </xsl:text>
              <xsl:call-template name="psmi:name-this"/>
            </xsl:message>
          </xsl:if-->
        </xsl:if>

        <!--only preserve specified initial-page-number= on first page sequence
            that is not psmi:page-sequence.
            Changed: Preserve @initial-page-number for first occurence that is not cover.
            2015-08-26 t.makita
         -->
        <!--xsl:if test="not(preceding-sibling::*)">
          <xsl:copy-of select="../../@initial-page-number"/>      
        </xsl:if-->
        <xsl:choose>
          <xsl:when test="ahf:isFirstNonPsmiPageSeqOrPsmiPageSeqWoCover(.)">
            <xsl:copy-of select="../../@initial-page-number"/>
          </xsl:when>
          <xsl:when test="self::psmi:page-sequence">
            <xsl:copy-of select="@initial-page-number[string(.) = ('auto','auto-odd','auto-even','inherit')]"/>
          </xsl:when>
        </xsl:choose>
        
        <!--only preserve specified force-page-count= on last page sequence
            FIX: Remove setting attribute force-page-count="no-force"
                 because there is need to set this attribute for other value.
                 2011/07/14 t.makita
         -->
        <xsl:if test="following-sibling::psmi:page-sequence or
                     self::psmi:page-sequence/following-sibling::*"><!--not last-->
          <!--xsl:attribute name="force-page-count">no-force</xsl:attribute-->
        </xsl:if>
    
        <xsl:choose>
          <xsl:when test="self::psmi:page-sequence">
                                     <!--psmi:page-sequence title has precedence-->
            <xsl:copy-of select="(../../fo:title|fo:title)[last()]"/>
                            <!--psmi:page-sequence static-content has precedence-->
            <xsl:copy-of select="fo:static-content"/>
                  <!--get other static-content not already in psmi:page-sequence-->
            <xsl:variable name="static-content-flow-names"
                          select="fo:static-content/@flow-name"/>
            <!-- FIX: It is not a good idea to copy the paretnt's fo:static-content
                      because there is a pattern that psmi:page-sequence does not
                      have corresponding fo:static-content.
                      2011-07-20 t.makita
             -->
            <!--xsl:for-each select="../../fo:static-content">
              <xsl:if test="not( @flow-name = $static-content-flow-names )">
                <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each-->
                                              <!--do the psmi:page-sequence flow-->
            <fo:flow>
              <xsl:if test="not(fo:flow)">
                <xsl:message>
                  <xsl:call-template name="psmi:name-this"/>
                  <xsl:text> requires a </xsl:text>
                  <xsl:text>&lt;{http://www.w3.org/1999/XSL/Format}flow&gt;</xsl:text>
                  <xsl:text> child</xsl:text>
                </xsl:message>
              </xsl:if>
              <xsl:for-each select="fo:flow">
                <xsl:copy-of select="@*"/>
                <xsl:if test="not(@flow-name)">
                  <xsl:message>
                    <xsl:text>&lt;{http://www.w3.org/1999/XSL/Format}flow&gt;</xsl:text>
                    <xsl:text> requires the "flow-name=" attribute.</xsl:text>
                  </xsl:message>
                </xsl:if>
                                        <!--all flow contents belong in sequence-->
                <xsl:apply-templates select="*"/>
              </xsl:for-each>
            </fo:flow>
          </xsl:when>
          <xsl:otherwise><!--only following siblings up to psmi:page-sequence-->
                         <!--use all of the fo:page-sequence's non-flow children-->
            <xsl:copy-of select="../../fo:title|../../fo:static-content"/>
                           <!--use all of the fo:page-sequence's flow attributes-->
            <fo:flow>
              <xsl:copy-of select="../@*"/>
                  <!--only use as much flow as up to the next psmi:page-sequence-->
              <xsl:call-template name="copy-until-psmi"/>
            </fo:flow>
          </xsl:otherwise>
        </xsl:choose>
      </fo:page-sequence>
                                   <!--move to the next need for a page sequence-->
      <xsl:choose>
        <xsl:when test="self::psmi:page-sequence">
          <xsl:apply-templates select="following-sibling::*[1]"
                               mode="psmi:do-flow-children"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="following-sibling::psmi:page-sequence[1]"
                               mode="psmi:do-flow-children"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template name="copy-until-psmi" mode="copy-until-psmi" match="*">
      <xsl:if test="not(self::psmi:page-sequence)">
        <xsl:call-template name="psmi:preserve"/><!--copy this element-->
        <xsl:apply-templates select="following-sibling::*[1]" 
                             mode="copy-until-psmi"/>
      </xsl:if>
    </xsl:template>
    
    
    <!--==========================================================================
      Handle the new semantic when found in the wrong context by reporting error.
    -->
    
    <xsl:template match="psmi:page-sequence" name="unexpected-psmi">
      <xsl:message terminate="yes">
        <xsl:text>Unexpected parent </xsl:text>
        <xsl:for-each select="..">
          <xsl:call-template name="psmi:name-this"/>
        </xsl:for-each>
        <xsl:text> for </xsl:text>
        <xsl:call-template name="psmi:name-this"/>
      </xsl:message>
      <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!--==========================================================================
      Default handlers for other constructs.
    -->
    
    <xsl:template match="psmi:*"><!--no other PSMI construct is defined-->
      <xsl:message>
        <xsl:text>Unrecognized construct ignored: </xsl:text>
        <xsl:call-template name="psmi:name-this"/>
      </xsl:message>
    </xsl:template>
    
    <xsl:template match="*" name="psmi:preserve"><!--other constructs preserved-->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:template>
    
    <xsl:template name="psmi:name-this">
      <xsl:value-of disable-output-escaping="yes"
                 select="concat('&lt;{',namespace-uri(),'}',local-name(),'&gt;')"/>
    </xsl:template>

</xsl:stylesheet>
