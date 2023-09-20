node {
	stage 'Checkout'
		checkout scm
	
	/* .. snip .. tst*/
	
	stage 'Build'
		sh 'terraform validate'
		sh 'terraform fmt'
}
