@isTest
private class CSVReader_Test {

	// r1c1 = r1c1
	@isTest static void simple_parse_n() {
		String csvString = 'r1c1,r1c2\nr2c1,r2c2';
		List<List<String>> rows = CSVReader.Parse(csvString);
		System.assertEquals(2, rows.size(), 'Row Count');
		System.assertEquals(2, rows.get(0).size(), 'Row1 Column Count');
		for (Integer r = 0; r < 2; r++)
			for (Integer c = 0; c < 2; c++)
				System.assertEquals('r' + (r+1) + 'c' + (c+1), rows.get(r).get(c), 'Row ' + (r+1) + ' Column ' + (c+1));
	}

	// r1c1 = r1c1
	@isTest static void simple_parse_r() {
		String csvString = 'r1c1,r1c2\rr2c1,r2c2';
		List<List<String>> rows = CSVReader.Parse(csvString);
		System.assertEquals(2, rows.size(), 'Row Count');
		System.assertEquals(2, rows.get(0).size(), 'Row1 Column Count');
		for (Integer r = 0; r < 2; r++)
			for (Integer c = 0; c < 2; c++)
				System.assertEquals('r' + (r+1) + 'c' + (c+1), rows.get(r).get(c), 'Row ' + (r+1) + ' Column ' + (c+1));
	}

	// r1c1 = r1c1
	@isTest static void simple_parse_rn() {
		String csvString = 'r1c1,r1c2\r\nr2c1,r2c2';
		List<List<String>> rows = CSVReader.Parse(csvString);
		System.assertEquals(2, rows.size(), 'Row Count');
		System.assertEquals(2, rows.get(0).size(), 'Row1 Column Count');
		for (Integer r = 0; r < 2; r++)
			for (Integer c = 0; c < 2; c++)
				System.assertEquals('r' + (r+1) + 'c' + (c+1), rows.get(r).get(c), 'Row ' + (r+1) + ' Column ' + (c+1));
	}

	// 'r1c1' = 'r1c1'
	@isTest static void single_quote_parse() {
		String csvString = '\'r1c1\',\'r1c2\'\n\'r2c1\',\'r2c2\'';
		List<List<String>> rows = CSVReader.Parse(csvString);
		System.assertEquals(2, rows.size(), 'Row Count');
		System.assertEquals(2, rows.get(0).size(), 'Row1 Column Count');
		for (Integer r = 0; r < 2; r++)
			for (Integer c = 0; c < 2; c++)
				System.assertEquals('\'r' + (r+1) + 'c' + (c+1) + '\'', rows.get(r).get(c), 'Row ' + (r+1) + ' Column ' + (c+1));
	}

	// "r1c1" = r1c1
	@isTest static void double_quote_parse() {
		String csvString = '"r1c1","r1c2"\n"r2c1","r2c2"';
		List<List<String>> rows = CSVReader.Parse(csvString);
		System.assertEquals(2, rows.size(), 'Row Count');
		System.assertEquals(2, rows.get(0).size(), 'Row1 Column Count');
		for (Integer r = 0; r < 2; r++)
			for (Integer c = 0; c < 2; c++)
				System.assertEquals('r' + (r+1) + 'c' + (c+1), rows.get(r).get(c), 'Row ' + (r+1) + ' Column ' + (c+1));
	}

	// "r1'c1" = r1'c1
	@isTest static void mixed_quote1_parse() {
		String csvString = '"r1\'c1","r1\'c2"\n"r2\'c1","r2\'c2"';
		List<List<String>> rows = CSVReader.Parse(csvString);
		System.assertEquals(2, rows.size(), 'Row Count');
		System.assertEquals(2, rows.get(0).size(), 'Row1 Column Count');
		for (Integer r = 0; r < 2; r++)
			for (Integer c = 0; c < 2; c++)
				System.assertEquals('r' + (r+1) + '\'c' + (c+1), rows.get(r).get(c), 'Row ' + (r+1) + ' Column ' + (c+1));
	}

	// 'r1"c1' = 'r1"c1'
	@isTest static void mixed_quote2_parse() {
		String csvString = '\'r1"c1\',\'r1"c2\'\n\'r2"c1\',\'r2"c2\'';
		List<List<String>> rows = CSVReader.Parse(csvString);
		System.assertEquals(2, rows.size(), 'Row Count');
		System.assertEquals(2, rows.get(0).size(), 'Row1 Column Count');
		for (Integer r = 0; r < 2; r++)
			for (Integer c = 0; c < 2; c++)
				System.assertEquals('\'r' + (r+1) + '"c' + (c+1) + '\'', rows.get(r).get(c), 'Row ' + (r+1) + ' Column ' + (c+1));
	}
}