node {
	stage ('Checkout') {
	        checkout scm
	}
	
	/* .. snip ..1 */
	
	stage ('Build') {
		sh 'cd linux-basic-ssh'
		sh 'terraform validate'
		sh 'terraform fmt'
	}

	stage ('Apply') {
		sh 'terraform plan'
		sh 'terraform apply'
	}
}
