"""Static consistency checks; a Windows/Delphi build is still required."""
import pathlib
import re
import unittest
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]


class ProjectConsistencyTests(unittest.TestCase):
    def test_project_references_and_platforms(self):
        root = ET.parse(ROOT / 'EOBSIM.dproj').getroot()
        ns = {'m': 'http://schemas.microsoft.com/developer/msbuild/2003'}
        self.assertEqual(root.find('.//m:MainSource', ns).text, 'EOBSIM.dpr')
        for item in root.findall('.//m:DCCReference', ns):
            self.assertTrue((ROOT / item.attrib['Include']).is_file())
        platforms = {item.attrib['value']: item.text for item in root.findall('.//m:Platforms/m:Platform', ns)}
        self.assertEqual(platforms, {'Win32': 'True', 'Win64': 'True'})
        self.assertIn('$(SESCOMPONENTS_DIR)', (ROOT / 'EOBSIM.dproj').read_text())
        self.assertNotIn('<DCC_UsePackage>', (ROOT / 'EOBSIM.dproj').read_text())

    def test_help_and_file_association_are_consistent(self):
        main = (ROOT / 'EOBSIMMain.pas').read_text()
        script = (ROOT / 'EOBSIM.iss').read_text()
        self.assertIn("DataFileExtension = '.EOB'", main)
        self.assertIn('SameText(ExtractFileExt(FileName), DataFileExtension)', main)
        self.assertIn('EOSIM-help.html', main)
        self.assertIn('EOSIM-help.html', script)
        self.assertTrue((ROOT / 'EOSIM-help.html').is_file())
        self.assertIn('"%1"', script)

    def test_concentrations_are_not_cast_directly_to_pointers(self):
        main = (ROOT / 'EOBSIMMain.pas').read_text()
        self.assertNotRegex(main, r'TObject\(x\)|Single\(\s*cb\w+StockConc\.Items\.Objects')
        self.assertEqual(main.count('StockConcentration := DecodeConcentration('), 3)
        self.assertIn('Move(Value, Bits, SizeOf(Bits))', main)
        self.assertIn('Move(Bits, Result, SizeOf(Bits))', main)


if __name__ == '__main__':
    unittest.main()
