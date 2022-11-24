package com.antennahouse.ant_utils;
//import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class StringPattern {
	public static Pattern basicLatinPattern = Pattern.compile("(?U)^[\\p{InBasicLatin}]+$");
	private static Pattern digitPattern = Pattern.compile("^[0-9]+$");
	private static Pattern regexPattern = Pattern.compile("^[\\.\\^\\$\\*\\+\\?\\{\\}\\(\\)\\|\\[\\]]+$");
	
	/**
	 * Return parameter is composed of all digit character
	 * @param srcString
	 * @return boolean
	 */
	public static boolean isDigit(String srcString) {
		return digitPattern.matcher(srcString).matches();
	}
	/**
	 * Return parameter is composed of regular expression meta-characters
	 * @param srcString
	 * @return boolean
	 */
	public static boolean isRegExMetaChars(String srcString) {
		return regexPattern.matcher(srcString).matches();
	}
	/**
	 * Return parameter is composed of all Latin1 character
	 * @param srcString
	 * @return boolean
	 */
	public static boolean isAllBasicLatin(String srcString) {
		return basicLatinPattern.matcher(srcString).matches();
	}
}
