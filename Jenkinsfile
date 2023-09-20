node {
	stage 'Checkout'
		checkout scm
	
	/* .. snip .. */
	
	stage 'Build'
		sh 'terraform validate'
		sh 'terraform fmt'
}
