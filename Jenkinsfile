node {
	stage 'Checkout'
		checkout scm

	stage 'Build'
		bat 'terraform validate'
		bat 'terraform fmt'
}
