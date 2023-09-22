node {
	stage ('Checkout') {
	        checkout scm
	}
	
	/* .. snip .. */
	
	stage ('Build') {
		sh 'cd linux-basic-ssh'
		sh 'terraform validate'
		sh 'terraform fmt'
	}
}
