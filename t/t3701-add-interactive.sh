diff_cmp () {
	for x
	do
		sed  -e '/^index/s/[0-9a-f]*[1-9a-f][0-9a-f]*\.\./1234567../' \
		     -e '/^index/s/\.\.[0-9a-f]*[1-9a-f][0-9a-f]*/..9abcdef/' \
		     -e '/^index/s/ 00*\.\./ 0000000../' \
		     -e '/^index/s/\.\.00*$/..0000000/' \
		     -e '/^index/s/\.\.00* /..0000000 /' \
		     "$x" >"$x.filtered"
	done
	test_cmp "$1.filtered" "$2.filtered"
}

	cat >expected <<-\EOF
	new file mode 100644
	index 0000000..d95f3ad
	--- /dev/null
	+++ b/file
	@@ -0,0 +1 @@
	+content
	EOF
	diff_cmp expected diff
	cat >expected <<-\EOF
	index 180b47c..b6f2c08 100644
	--- a/file
	+++ b/file
	@@ -1 +1,2 @@
	 baseline
	+content
	EOF
	diff_cmp expected diff
	cat >expected <<-\EOF
	EOF
	test_set_editor : &&
	diff_cmp expected diff
	cat >patch <<-\EOF
	@@ -1,1 +1,4 @@
	 this
	+patch
	-does not
	 apply
	EOF
	write_script "fake_editor.sh" <<-\EOF &&
	mv -f "$1" oldpatch &&
	mv -f patch "$1"
	EOF
	cat >patch <<-\EOF
	this patch
	is garbage
	EOF
	cat >patch <<-\EOF
	@@ -1,0 +1,0 @@
	 baseline
	+content
	+newcontent
	+lines
	EOF
	cat >expected <<-\EOF
	diff --git a/file b/file
	index b5dd6c9..f910ae9 100644
	--- a/file
	+++ b/file
	@@ -1,4 +1,4 @@
	 baseline
	 content
	-newcontent
	+more
	 lines
	EOF
	diff_cmp expected output
'

test_expect_success 'setup file' '
	test_write_lines a "" b "" c >file &&
	git add file &&
	test_write_lines a "" d "" c >file
'

test_expect_success 'setup patch' '
	SP=" " &&
	NULL="" &&
	cat >patch <<-EOF
	@@ -1,4 +1,4 @@
	 a
	$NULL
	-b
	+f
	$SP
	c
	EOF
'

test_expect_success 'setup expected' '
	cat >expected <<-EOF
	diff --git a/file b/file
	index b5dd6c9..f910ae9 100644
	--- a/file
	+++ b/file
	@@ -1,5 +1,5 @@
	 a
	$SP
	-f
	+d
	$SP
	 c
	EOF
'

test_expect_success 'edit can strip spaces from empty context lines' '
	test_write_lines e n q | git add -p 2>error &&
	test_must_be_empty error &&
	git diff >output &&
	diff_cmp expected output
	diff_cmp expected output &&
	cat >patch <<-\EOF
	index 180b47c..b6f2c08 100644
	--- a/file
	+++ b/file
	@@ -1,2 +1,4 @@
	+firstline
	 baseline
	 content
	+lastline
	\ No newline at end of file
	EOF
'

# Expected output, diff is similar to the patch but w/ diff at the top
	echo diff --git a/file b/file >expected &&
	cat patch |sed "/^index/s/ 100644/ 100755/" >>expected &&
	cat >expected-output <<-\EOF
	--- a/file
	+++ b/file
	@@ -1,2 +1,4 @@
	+firstline
	 baseline
	 content
	+lastline
	\ No newline at end of file
	@@ -1,2 +1,3 @@
	+firstline
	 baseline
	 content
	@@ -1,2 +2,3 @@
	 baseline
	 content
	+lastline
	\ No newline at end of file
	EOF
test_expect_success C_LOCALE_OUTPUT 'add first line works' '
	printf "%s\n" s y y | git add -p file 2>error |
		sed -n -e "s/^Stage this hunk[^@]*\(@@ .*\)/\1/" \
		       -e "/^[-+@ \\\\]"/p  >output &&
	test_must_be_empty error &&
	git diff --cached >diff &&
	diff_cmp expected diff &&
	test_cmp expected-output output
	cat >expected <<-\EOF
	diff --git a/non-empty b/non-empty
	deleted file mode 100644
	index d95f3ad..0000000
	--- a/non-empty
	+++ /dev/null
	@@ -1 +0,0 @@
	-content
	EOF
	diff_cmp expected diff
	cat >expected <<-\EOF
	diff --git a/empty b/empty
	deleted file mode 100644
	index e69de29..0000000
	EOF
	diff_cmp expected diff
	test_write_lines 10 20 30 40 50 60 >test &&
	test_write_lines 10 15 20 21 22 23 24 30 40 50 60 >test
	test_write_lines 5 10 20 21 30 31 40 50 60 >test &&