<?xml version="1.0" encoding="UTF-8" ?>
<!--
    **************************************************************
    DITA to XSL-FO Stylesheet
    Node Related Utility Templates
    **************************************************************
    File Name : dita2xslfo_util_node.xsl
    **************************************************************
    Copyright © 2009-2019 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL : http://www.antennahouse.com/
    **************************************************************
-->

<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" >

    <!-- 
      ============================================
         Node functions
      ============================================
    -->
    
    <!-- 
     function:  determine empty element
     param:     prmElem
     return:    xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isNotEmptyElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:sequence select="not(ahf:isEmptyElement($prmElem))"/>
    </xsl:function>        
    
    <xsl:function name="ahf:isEmptyElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:choose>
            <xsl:when test="empty($prmElem)">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="empty($prmElem/node())">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="every $node in $prmElem/node() satisfies ahf:isRedundantNode($node)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:  determine redundant node
     param:     prmNode
     return:    xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isRedundantNode" as="xs:boolean">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:choose>
            <xsl:when test="$prmNode/self::comment()">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::processing-instruction()">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::text()">
                <xsl:choose>
                    <xsl:when test="string(normalize-space($prmNode)) eq ''">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$prmNode/self::element()">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:  determine redundant nodes
     param:     prmNodes
     return:    xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isRedundantNodes" as="xs:boolean">
        <xsl:param name="prmNodes" as="node()+"/>
        <xsl:sequence select="every $node in $prmNodes satisfies ahf:isRedundantNode($node)"/>
    </xsl:function>

    <!-- 
     function:  Get first preceding elememnt
     param:     prmElem
     return:    element()?
     note:		
     -->
    <xsl:function name="ahf:getFirstPrecedingSiblingElemWoWh" as="element()?">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:variable name="precedingFirstElem" as="element()?" select="$prmElem/preceding-sibling::*[1]"/>
        <xsl:choose>
            <xsl:when test="empty($precedingFirstElem)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="nodesBetween" as="node()*" select="$prmElem/preceding-sibling::node()[. &gt;&gt; $precedingFirstElem]"/>
                <xsl:choose>
                    <xsl:when test="empty($nodesBetween)">
                        <xsl:sequence select="$precedingFirstElem"/>
                    </xsl:when>
                    <xsl:when test="every $node in $nodesBetween satisfies ahf:isRedundantNode($node)">
                        <xsl:sequence select="$precedingFirstElem"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:  Get first following elememnt
     param:     prmElem
     return:    element()?
     note:		
     -->
    <xsl:function name="ahf:getFirstFollowingSiblingElemWoWh" as="element()?">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:variable name="followingFirstElem" as="element()?" select="$prmElem/following-sibling::*[1]"/>
        <xsl:choose>
            <xsl:when test="empty($followingFirstElem)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="nodesBetween" as="node()*" select="$prmElem/following-sibling::node()[. &lt;&lt; $followingFirstElem]"/>
                <xsl:choose>
                    <xsl:when test="empty($nodesBetween)">
                        <xsl:sequence select="$followingFirstElem"/>
                    </xsl:when>
                    <xsl:when test="every $node in $nodesBetween satisfies ahf:isRedundantNode($node)">
                        <xsl:sequence select="$followingFirstElem"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:  Determine the first child of parent
     param:     prmElem
     return:    xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isFirstChildOfParent" as="xs:boolean">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:sequence select="$prmElem[parent::*/*[1] is $prmElem] => exists()"/>
    </xsl:function>
    
    <!-- 
     function:  Determine the last child of parent
     param:     prmElem
     return:    xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isLastChildOfParent" as="xs:boolean">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:sequence select="$prmElem[parent::*/*[last()] is $prmElem] => exists()"/>
    </xsl:function>

    <!-- end of stylesheet -->
</xsl:stylesheet>
