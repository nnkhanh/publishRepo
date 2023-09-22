node {
	stage ('Checkout') {
	        checkout scm
	}
	
	/* .. snip ..2 */
	
	stage ('Build') {
		sh 'cd linux-basic-ssh'
		sh 'pwd && ls'
		sh 'terraform init'
		sh 'terraform validate'
	}

	stage ('Apply') {
		sh 'terraform plan'
		sh 'terraform apply -auto-approve'
	}

	stage ('Destroy') {
		sh 'terraform destroy -auto-approve'
	}
}
