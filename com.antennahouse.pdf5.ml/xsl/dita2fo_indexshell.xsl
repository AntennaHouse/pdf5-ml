<?xml version="1.0" encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Index shell template
    Copyright © 2009-2021 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
 xmlns:i18n_index_saxon9="java:jp.co.antenna.ah_i18n_index.IndexSortSaxon9"
 extension-element-prefixes="i18n_index_saxon9"
 exclude-result-prefixes="xs ahf i18n_index_saxon9"
>
    <!-- Use I18n Index Library -->
    <xsl:include href="dita2fo_indexi18n.xsl" use-when="system-property('use.i18n.index.lib') eq 'yes'"/>
    
    <!-- Does not use I18n Index Library. Use xsl:sort for index sorting. -->
    <xsl:include href="dita2fo_index.xsl"     use-when="not(system-property('use.i18n.index.lib') eq 'yes')"/>
    <xsl:include href="dita2fo_indexsort.xsl" use-when="not(system-property('use.i18n.index.lib') eq 'yes')"/>
     
    <!-- Common template
         Experimental index processing refinement:
         1. Do not generate @id for indexterm unless it is referenced by index-see, index-see-also.
         2. If @seekey duplicates for multiple indexterms, generate @id only for first occurrence to avoid @id duplication.
         3. Output warning message if index-see, index-see-also target is not found. 
         2021-05-22 t.makita
     -->
    <!--*-->
    <xsl:include href="dita2fo_indexcommon.xsl"                  use-when="system-property('use.index.common.xslt3') ne 'yes' or xs:double(substring((system-property('ot.version')),1 ,3)) lt 3.4"/>
    <xsl:include href="dita2fo_indexcommon_indexterm.xsl"        use-when="system-property('use.index.common.xslt3') eq 'yes' and xs:double(substring((system-property('ot.version')),1 ,3)) ge 3.4"/>
    <xsl:include href="dita2fo_indexcommon_index_out.xsl"        use-when="system-property('use.index.common.xslt3') eq 'yes' and xs:double(substring((system-property('ot.version')),1, 3)) ge 3.4"/>
    <xsl:include href="dita2fo_indexcommon_index_final_tree.xsl" use-when="system-property('use.index.common.xslt3') eq 'yes' and xs:double(substring((system-property('ot.version')),1, 3)) ge 3.4"/>
    <!--*-->

    <!--xsl:include href="dita2fo_indexcommon_indexterm.xsl"/>
    <xsl:include href="dita2fo_indexcommon_index_out.xsl"/>
    <xsl:include href="dita2fo_indexcommon_index_final_tree.xsl"/-->
    
</xsl:stylesheet>
