node {
	stage ('Checkout') {
	        checkout scm
	}
	
	/* .. snip ..2 */
	
	stage ('Build') {

		dir('linux-basic-ssh') {
      			sh "pwd && ls"
		}		

		sh 'terraform init'
		sh 'terraform validate'
	}

	stage ('Apply') {
		sh 'terraform apply -auto-approve'
	}

	stage ('Destroy') {
		sh 'terraform destroy -auto-approve'
	}
}
