node {
	stage ('Checkout') {
	        checkout scm
	}
	
	/* .. snip ..2 */
	
	stage ('Build') {
		sh 'cd linux-basic-ssh'
		sh 'terraform validate'
		sh 'terraform fmt'
	}

	stage ('Apply') {
		sh 'terraform init'
		sh 'terraform apply -auto-approve'
	}

	stage ('Destroy') {
		sh 'terraform destroy -auto-approve'
	}
}
