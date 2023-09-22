node {
	stage ('Checkout') {
	        checkout scm
	}
	
	/* .. snip ..1 */
	
	stage ('Build') {
		sh 'cd linux-basic-ssh'
		sh 'terraform validate'
		sh 'terraform fmt'
		sh 'terraform apply'
	}

	stage ('Apply') {		
		sh 'terraform apply'
	}
}
