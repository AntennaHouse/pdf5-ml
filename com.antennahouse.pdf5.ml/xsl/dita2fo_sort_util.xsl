<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="2.0">
    <!--
    ****************************************************************
    DITA to XSL-FO Stylesheet 
    Module: Sorting utility template
    Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
    -->
    
    <!--
     function:	Get sort-as
     param:		prmElem
     return:	xs:string (Return '' if not exists) 
     note:		
     -->
    <xsl:function name="ahf:getSortAs" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:choose>
            <xsl:when test="$prmElem[contains(@class, ' map/topicref ')]">
                <xsl:choose>
                    <xsl:when test="$prmElem/*[contains(@class, ' ut-d/sort-as ')]">
                        <xsl:sequence select="ahf:processSortAs($prmElem/*[contains(@class, ' ut-d/sort-as ')][1])"/>
                    </xsl:when>
                    <xsl:when test="$prmElem/*[contains(@class,' map/topicmeta ')]/*[contains(@class, ' ut-d/sort-as ')]">
                        <xsl:sequence select="ahf:processSortAs($prmElem/*[contains(@class,' map/topicmeta ')]/*[contains(@class, ' ut-d/sort-as ')][1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="topic" as="element()?" select="ahf:getTopicFromTopicRef($prmElem)"/>
                        <xsl:choose>
                            <xsl:when test="exists($topic)">
                                <xsl:choose>
                                    <xsl:when test="$topic/*[contains(@class,' topic/title ')]/*[contains(@class, ' ut-d/sort-as ')]">
                                        <xsl:sequence select="ahf:processSortAs($topic/*[contains(@class,' topic/title ')]/*[contains(@class, ' ut-d/sort-as ')][1])"/>
                                    </xsl:when>
                                    <xsl:when test="$topic/*[contains(@class,' topic/prolog ')]/*[contains(@class, ' ut-d/sort-as ')]">
                                        <xsl:sequence select="ahf:processSortAs($topic/*[contains(@class,' topic/prolog ')]/*[contains(@class, ' ut-d/sort-as ')][1])"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="''"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>                
            </xsl:when>
            <xsl:when test="$prmElem[contains(@class, ' topic/topic ')]">
                <xsl:choose>
                    <xsl:when test="$prmElem/*[contains(@class,' topic/title ')]/*[contains(@class, ' ut-d/sort-as ')]">
                        <xsl:sequence select="ahf:processSortAs($prmElem/*[contains(@class,' topic/title ')]/*[contains(@class, ' ut-d/sort-as ')][1])"/>
                    </xsl:when>
                    <xsl:when test="$prmElem/*[contains(@class,' topic/prolog ')]/*[contains(@class, ' ut-d/sort-as ')]">
                        <xsl:sequence select="ahf:processSortAs($prmElem/*[contains(@class,' topic/prolog ')]/*[contains(@class, ' ut-d/sort-as ')][1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$prmElem/*[contains(@class, ' ut-d/sort-as ')]">
                        <xsl:sequence select="ahf:processSortAs($prmElem/*[contains(@class, ' ut-d/sort-as ')][1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
     function:	Process sort-as
     param:		prmSortAs
     return:	xs:string (Return '' if not exists) 
     note:		
     -->
    <xsl:function name="ahf:processSortAs" as="xs:string">
        <xsl:param name="prmSortAs" as="element()"/>
        <xsl:choose>
            <xsl:when test="$prmSortAs/@value">
                <xsl:sequence select="normalize-space($prmSortAs/@value)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sortAsText" as="xs:string*">
                    <xsl:apply-templates select="$prmSortAs/node()" mode="TEXT_ONLY"/>
                </xsl:variable>
                <xsl:sequence select="normalize-space(string-join($sortAsText,''))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>