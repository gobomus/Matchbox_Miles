#!/usr/bin/env python
import os, glob, shlex, subprocess, sys, shutil

# Only proceed if sudo or root
# Run myself via sudo :-)
if os.getuid() != 0:
    
    print("You need to be root or have sudo to run the installer")
    print("I will now ask you for your account password.")
    print("If this doesn't work then you probably have a Linux IFFS system,")
    print("and you have to run this installer as root.")
    
    cmd = 'sudo "%s"' % __file__
    subprocess.call(shlex.split(cmd))
    exit(0)

print("Shader installer running py-%s" % (sys.version))
pkgdir = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'shaders')
files = glob.glob(pkgdir + "/*.glsl") + glob.glob(pkgdir + "/*.glsl.p") + glob.glob(pkgdir + "/*.xml")

# Find all Matchbox directories
matchbox_directories = glob.glob("/usr/discreet/*/matchbox")
for destination in matchbox_directories:
    if not os.access(destination, os.W_OK):
        sys.stderr.write("We cannot write to your IFFS directories.\n")
        sys.stderr.write("You need to run this installer as root or via sudo\n")
        sys.stderr.write("Aborting...\n")
        exit(1)

def soft_remove(in_dir, filename):
    path = os.path.join(in_dir, filename)
    if os.path.isfile(path):
        os.remove(path)
    
def delete_obsolete_shaders(logik_dir):
    soft_remove(logik_dir, "Ash.1.glsl")
    soft_remove(logik_dir, "Ash.1.glsl.p")
    soft_remove(logik_dir, "Ash.2.glsl")
    soft_remove(logik_dir, "Ash.3.glsl")
    soft_remove(logik_dir, "Ash.xml")
    soft_remove(logik_dir, "Checker.glsl")
    soft_remove(logik_dir, "Colourmatrix.glsl")
    soft_remove(logik_dir, "Colourmatrix.glsl.p")
    soft_remove(logik_dir, "Colourmatrix.xml")
    soft_remove(logik_dir, "Contacts.glsl")
    soft_remove(logik_dir, "Contacts.glsl.p")
    soft_remove(logik_dir, "Contacts.xml")
    soft_remove(logik_dir, "Dollface.1.glsl")
    soft_remove(logik_dir, "Dollface.1.glsl.p")
    soft_remove(logik_dir, "Dollface.2.glsl")
    soft_remove(logik_dir, "Dollface.xml")
    soft_remove(logik_dir, "Nail.glsl")
    soft_remove(logik_dir, "Nail.glsl.p")
    soft_remove(logik_dir, "Nail.xml")
    soft_remove(logik_dir, "Posmatte.glsl")
    soft_remove(logik_dir, "Posmatte.glsl.p")
    soft_remove(logik_dir, "Posmatte.xml")
    soft_remove(logik_dir, "Splineblur.1.glsl")
    soft_remove(logik_dir, "Splineblur.1.glsl.p")
    soft_remove(logik_dir, "Splineblur.2.glsl")
    soft_remove(logik_dir, "Splineblur.xml")
    soft_remove(logik_dir, "Tinyplanet.glsl")
    soft_remove(logik_dir, "Tinyplanet.glsl.p")
    soft_remove(logik_dir, "Tinyplanet.xml")
    soft_remove(logik_dir, "UVewa.glsl")
    soft_remove(logik_dir, "UVewa.glsl.p")
    soft_remove(logik_dir, "UVewa.xml")
    soft_remove(logik_dir, "Wireless.glsl")
    soft_remove(logik_dir, "Wireless.glsl.p")
    soft_remove(logik_dir, "Wireless.xml")
    
for destination in matchbox_directories:
    logik_dir = os.path.join(destination, 'LOGIK')
    # Create the LOGIK subdir in the shader directory
    if not os.path.isdir(logik_dir):
        os.makedirs(logik_dir)
    print("Installing the Matchbox shaders into:")
    print(logik_dir)
    
    delete_obsolete_shaders(logik_dir)
    
    for shader_file in files:
        dest_path = os.path.join(logik_dir, os.path.basename(shader_file))
        shutil.copyfile(shader_file, dest_path)
        sys.stdout.write(".")
    sys.stdout.write("\n")
