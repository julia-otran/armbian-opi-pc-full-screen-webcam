function post_install_kernel_debs__install_libc() {
	install_deb_chroot "${DEB_STORAGE}/linux-libc-dev_${REVISION}_${ARCH}.deb"
}
