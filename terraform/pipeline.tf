resource "aws_codebuild_project" "tf-plan" {
  name          = "tf-cicd-plan"
  description   = "Plan stage for terraform"
  build_timeout = "5"
  service_role  = aws_iam_role.ProjectRole.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply" {
  name          = "tf-cicd-apply"
  description   = "Apply stage for terraform"
  build_timeout = "5"
  service_role  = aws_iam_role.ProjectRole.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}

resource "aws_codepipeline" "cicd_pipeline" {

  name     = "tf-cicd"
  #role_arn = aws_iam_role.tf-codepipeline-role.arn
  role_arn = aws_iam_role.apps_codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]
      configuration = {
        FullRepositoryId     = "brvendrametto/aws-cicd-pipeline/tree/main/terraform"
        BranchName           = "main"
        ConnectionArn        = var.codestar_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }


  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name     = "Deploy"
      category = "Build"
      provider = "CodeBuild"
      version  = "1"
      owner    = "AWS"
      region   = var.aws_region //TODO:Verificar region Deploy
      //Essa integração está disponível nas regiões do Leste dos EUA (Ohio), Leste dos EUA (Virgínia), Oeste dos EUA (Oregon), Oeste dos EUA (Norte da Califórnia), Canadá (Central), UE (Londres), UE (Irlanda), UE (Frankfurt), Ásia-Pacífico (Sydney), Ásia-Pacífico (Cingapura), Ásia-Pacífico (Tóquio) e Ásia-Pacífico (Seul).
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }


}