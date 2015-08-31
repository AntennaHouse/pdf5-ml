<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Document check stylesheet
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
     function:	Document check template
     param:		none
     return:	none
     note:		
     -->
    <xsl:template name="documentCheck">
        <!-- Document structure check -->
        <xsl:variable name="checkBookmap1" select="ahf:checkBookmap1()" as="xs:boolean"/>
        <xsl:variable name="checkBookmap2" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$checkBookmap1">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ahf:checkBookmap2()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="checkBookmap3" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$checkBookmap2">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ahf:checkBookmap3()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$checkBookmap3">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes" select="$stMes599"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$pUseOid">
            <xsl:call-template name="checkId"/>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	bookmap structure check (1)
     param:		
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:checkBookmap1" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$isPartExist and $isChapterExist">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes"
                                    select="ahf:replace($stMes503,('%xtrf'),($map/@xtrf))"/>
                </xsl:call-template>
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	bookmap structure check (2)
     param:		
     return:	xs:boolean
     note:		Removed toc="no" restriction for part and chapter.
                2014-06-21 t.makita
     -->
    <xsl:function name="ahf:checkBookmap2" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$isPartExist">
                <!--xsl:choose>
                    <!-\-xsl:when test="$map/*[contains(@class, ' bookmap/part ')][@toc='no']"-\->
                    <xsl:when test="$map/*[contains(@class, ' bookmap/part ')][ahf:isTocNo(.)]">
                        <xsl:for-each select="$map/*[contains(@class, ' bookmap/part ')][@toc='no']">
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes"
                                 select="ahf:replace($stMes504,('%ohref','%xtrf'),(if (@ohref) then @ohref else ' ' ,@xtrf))"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>
                </xsl:choose-->
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="$isChapterExist">
                <!--xsl:choose>
                    <!-\-xsl:when test="$map/*[contains(@class, ' bookmap/chapter ')][@toc='no']"-\->
                    <xsl:when test="$map/*[contains(@class, ' bookmap/chapter ')][ahf:isTocNo(.)]">
                        <xsl:for-each select="$map/*[contains(@class, ' bookmap/chapter ')][@toc='no']">
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes"
                                 select="ahf:replace($stMes505,('%ohref','%xtrf'),(if (@ohref) then @ohref else ' ',@xtrf))"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>
                </xsl:choose-->
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	bookmap structure check (2)
     param:		
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:checkBookmap3" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:choose>
                    <!-- Make them as obsolete
                    <xsl:when test="count($map//*[contains(@class, ' bookmap/figurelist ')][not(@href)]) &gt; 1">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                            select="ahf:replace($stMes510,('%xtrf'),($map/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="count($map//*[contains(@class, ' bookmap/tablelist ')][not(@href)]) &gt; 1">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                            select="ahf:replace($stMes511,('%xtrf'),($map/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="count($map//*[contains(@class, ' bookmap/toc ')][not(@href)]) &gt; 1">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                            select="ahf:replace($stMes512,('%xtrf'),($map/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="count($map//*[contains(@class, ' bookmap/indexlist ')][not(@href)]) &gt; 1">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                            select="ahf:replace($stMes513,('%xtrf'),($map/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    -->
                    <xsl:when test="exists($map/*[contains(@class, ' bookmap/frontmatter ')]//*[contains(@class, ' bookmap/indexlist ')][not(@href)])">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes"
                                select="ahf:replace($stMes514,('%xtrf'),($map/@xtrf))"/>
                        </xsl:call-template>
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- 
     function:	topic/@id check template
     param:		
     return:	none
     note:		topic/@oid must be unique according to the DITA specification.
     -->
    <xsl:template name="checkId">
    	<xsl:if test="$pUseOid">
    	    <xsl:apply-templates select="$map//*[contains(@class, ' map/topicref ')][starts-with(@href,'#')][not(ancestor::*[contains(@class,' map/reltable ')])]" mode="CHECK_ID">
    	    </xsl:apply-templates>
    	</xsl:if>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="CHECK_ID">
        <xsl:variable name="topic" select="ahf:getTopicFromTopicRef(.)" as="element()?"/>
        <xsl:variable name="oid" select="$topic/@oid" as="xs:string?"/>
        
        <xsl:choose>
            <xsl:when test="empty($topic)">
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes"
                                    select="ahf:replace($stMes500,('%xtrf','%ohref'),(@xtrf,@ohref))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$topic/preceding::*[contains(@class,' topic/topic ')][@oid=$oid]">
                <xsl:variable name="sameXtrf" select="$topic/preceding::*[contains(@class,' topic/topic ')][@oid=$oid][1]/@xtrf"/>
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes"
                                    select="ahf:replace($stMes501,('%id','%xtrf1','%xtrf2'),($topic/@oid,$topic/@xtrf,$sameXtrf))"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>