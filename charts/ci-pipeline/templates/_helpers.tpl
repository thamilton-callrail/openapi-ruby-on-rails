

{{/*
Expand the name of the chart.
*/}}
{{- define "ci-pipeline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ci-pipeline.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ci-pipeline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ci-pipeline.labels" -}}
helm.sh/chart: {{ include "ci-pipeline.chart" . }}
{{ include "ci-pipeline.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ci-pipeline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ci-pipeline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate workflow name with prefix
*/}}
{{- define "ci-pipeline.workflowName" -}}
{{- if .Values.workflow.generateName }}
{{- printf "%s-ci-" (.Values.workflow.namePrefix | default .Values.ci.username) }}
{{- else }}
{{- printf "%s-ci-workflow" (.Values.workflow.namePrefix | default .Values.ci.username) }}
{{- end }}
{{- end }}

{{/*
Generate image tag from values
*/}}
{{- define "ci-pipeline.imageTag" -}}
{{- if .Values.ci.tag }}
{{- .Values.ci.tag }}
{{- else }}
{{- "{{`{{workflow.uid}}`}}" }}
{{- end }}
{{- end }}

{{/*
Generate full image name with tag
*/}}
{{- define "ci-pipeline.fullImageName" -}}
{{- printf "%s:%s" .Values.ci.image_name (include "ci-pipeline.imageTag" .) }}
{{- end }}

{{/*
Generate workflow template name
*/}}
{{- define "ci-pipeline.workflowTemplateName" -}}
{{- .Values.workflow.templateName | default "rails-ci-buildkit" }}
{{- end }}

{{/*
Generate workflow template namespace
*/}}
{{- define "ci-pipeline.workflowTemplateNamespace" -}}
{{- .Values.workflow.templateNamespace | default .Release.Namespace }}
{{- end }}

{{/*
Generate common annotations
*/}}
{{- define "ci-pipeline.annotations" -}}
ci-pipeline/chart: {{ include "ci-pipeline.chart" . }}
ci-pipeline/release: {{ .Release.Name }}
ci-pipeline/namespace: {{ .Release.Namespace }}
ci-pipeline/template: {{ include "ci-pipeline.workflowTemplateName" . }}
{{- end }}

{{/*
Generate GitHub URL from components
*/}}
{{- define "ci-pipeline.githubUrl" -}}
{{- if hasPrefix "https://" .Values.ci.repo_url }}
{{- .Values.ci.repo_url }}
{{- else }}
{{- printf "https://github.com/%s.git" .Values.ci.repo_url }}
{{- end }}
{{- end }}

{{/*
Generate GitHub secret name
*/}}
{{- define "ci-pipeline.githubSecretName" -}}
{{- .Values.github.secretName | default "github-token" }}
{{- end }}

{{/*
Generate workflow parameters
*/}}
{{- define "ci-pipeline.workflowParameters" -}}
- name: repo_url
  value: {{ include "ci-pipeline.githubUrl" . | quote }}
- name: branch
  value: {{ .Values.ci.branch | quote }}
- name: dockerfile
  value: {{ .Values.ci.dockerfile | quote }}
- name: context_path
  value: {{ .Values.ci.context_path | quote }}
- name: image_name
  value: {{ .Values.ci.image_name | quote }}
- name: image_tag
  value: {{ include "ci-pipeline.imageTag" . | quote }}
- name: test_command
  value: {{ .Values.ci.test_command | quote }}
- name: github_username
  value: {{ .Values.ci.username | quote }}
{{- end }}

