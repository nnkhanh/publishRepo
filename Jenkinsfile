node {
	stage 'Checkout'
		checkout scm

	stage 'Build'
		sh 'terraform validate'
		sh 'terraform fmt'
}
