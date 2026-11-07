#!/usr/bin/env python3
import os, shutil
import glob
from pathlib import Path

from SalomeOnDemandTK.extension_utilities import get_logger
from SalomeOnDemandTK.extension_remover import remove_salomex, AtRemoveAskerForce
extension_list = ["A","B","C","D","E","F"]
"""
metada/*.salomexd graph is :

depends_on_removed = {
    "A":[],
    "B":[],
    "C":[],
    "D":["B"],
    "E":["D","C"],
    "F":["E","A"]
}

depends_on = {
    "A":[],
    "B":[],
    "C":[],
    "D":[],
    "E":[],
    "F":["C"]
}
"""

virtual_appli_dir = "TestApp"

def prepare_virtual_appli():
    tmp_virtual_appli_dir = "TestApp_tmp"
    if os.path.isdir(tmp_virtual_appli_dir):
        shutil.rmtree(tmp_virtual_appli_dir)
    shutil.copytree(virtual_appli_dir, "TestApp_tmp")
    return tmp_virtual_appli_dir

def runtest(testnumber, removed_ext, ref_exts_tobe_removed):
    print(f"Test{testnumber}: Remove extension {removed_ext}")
    install_dir = os.path.realpath(prepare_virtual_appli())
    metadata_dir = os.path.join(install_dir,"ext_mng","metadata")

    ref_exts_remaining_extension = [ext for ext in extension_list if ext not in ref_exts_tobe_removed]

    ref_remaining_xdfiles = [str(Path(metadata_dir) / f"{ext}.salomexd") for ext in ref_exts_remaining_extension]

    print(f"Reference list of removed extensions:{ref_exts_tobe_removed}")
    print(f"Reference list of remaining extensions:{ref_exts_remaining_extension}")
    get_logger().info(f"Remove {removed_ext}")
    exts_tobe_removed = remove_salomex(install_dir, removed_ext, AtRemoveAskerForce(True), False)

    # Check contain of exts_tobe_removed
    if len(exts_tobe_removed) != len(list(set(exts_tobe_removed))):
        raise RuntimeError("duplication found in results of remove_salomex")

    if set( exts_tobe_removed ) != set( ref_exts_tobe_removed ):
        raise RuntimeError(f"Expecting {ref_exts_tobe_removed} having {exts_tobe_removed}")

    # Check contain of Test application dir
    remaining_xdfiles = glob.glob(os.path.join(metadata_dir,"*"))
    if set(remaining_xdfiles) != set(ref_remaining_xdfiles):
        print(f"reference list of remaining_xdfiles: {ref_remaining_xdfiles}")
        print(f"remaining_xdfiles list: {remaining_xdfiles}")
        raise RuntimeError(f"the contain of metadata directory is not correct")

if __name__ == '__main__':
    tests_list=[
        ("D",["B", "D"]),
        ("E",["B", "D", "E"]),
        ("F",["A", "B", "C", "D", "E", "F"])
    ]
    failed_test = []
    for idx, (mymodule, ref_moduleToKill) in enumerate( tests_list ):
        try:
            runtest(idx, mymodule, ref_moduleToKill)
        except Exception as e:
            raise RuntimeError( f"Fail for {mymodule} : Directly cause from exception {e}" )

