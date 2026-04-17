<?xml version="1.0" encoding="UTF-8"?>
<!--
    ****************************************************************
    DITA to FO Stylesheet
    Module: .job.xml to XML property file templates
    Copyright © 2017-2026 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf ahs" 
    >
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_constants.xsl"/>
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_util.xsl"/>
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_error_util.xsl"/>
    <xsl:import href="plugin:com.antennahouse.pdf5.ml:xsl/dita2fo_message.xsl/"/>
    
    <!-- 
     function:  job matching template
     param:     none
     return:    <job> element.
     note:      
     -->
    <xsl:template match="job">
        <xsl:element name="{name()}">
            <!-- Main map file -->
            <xsl:element name="user.input.file">
                <xsl:value-of select="./property[string(@name) eq 'user.input.file']/string"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>