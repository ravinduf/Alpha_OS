
if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/alphaos.flp ]
then
	echo ">>> Creating new Alpha_OS floppy image..."
	mkdosfs -C disk_images/alphaos.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit


echo ">>> Assembling Alpha_OS kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..


echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/alphaos.flp || exit


echo ">>> Copying Alpha_OS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/alphaos.flp tmp-loop && cp source/kernel.bin tmp-loop/

#cp programs/*.bin programs/*.bas programs/sample.pcx tmp-loop
cp programs/sample.pcx tmp-loop

sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/mikeos.iso
mkisofs -quiet -V 'ALPHAOS' -input-charset iso8859-1 -o disk_images/alphaos.iso -b alphaos.flp disk_images/ || exit

echo '>>> Done!'

