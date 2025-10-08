{{/*
Expand the name of the chart.
*/}}
{{- define "ci-pipeline-template.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ci-pipeline-template.fullname" -}}
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
{{- define "ci-pipeline-template.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ci-pipeline-template.labels" -}}
helm.sh/chart: {{ include "ci-pipeline-template.chart" . }}
{{ include "ci-pipeline-template.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ci-pipeline-template.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ci-pipeline-template.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate template name
*/}}
{{- define "ci-pipeline-template.templateName" -}}
{{- .Values.template.name | default "rails-ci-buildkit" }}
{{- end }}

{{/*
Generate template namespace
*/}}
{{- define "ci-pipeline-template.templateNamespace" -}}
{{- .Values.template.namespace | default .Release.Namespace }}
{{- end }}

{{/*
Generate common annotations
*/}}
{{- define "ci-pipeline-template.annotations" -}}
ci-pipeline-template/chart: {{ include "ci-pipeline-template.chart" . }}
ci-pipeline-template/release: {{ .Release.Name }}
ci-pipeline-template/namespace: {{ .Release.Namespace }}
{{- end }}

{{/*
Generate resource limits for general steps
*/}}
{{- define "ci-pipeline-template.resourceLimits" -}}
resources:
  limits:
    cpu: {{ .Values.template.resources.defaultLimits.cpu }}
    memory: {{ .Values.template.resources.defaultLimits.memory }}
  requests:
    cpu: {{ .Values.template.resources.defaultRequests.cpu }}
    memory: {{ .Values.template.resources.defaultRequests.memory }}
{{- end }}

{{/*
Generate resource limits for buildkit step
*/}}
{{- define "ci-pipeline-template.buildkitResourceLimits" -}}
resources:
  limits:
    cpu: {{ .Values.template.resources.buildkit.limits.cpu }}
    memory: {{ .Values.template.resources.buildkit.limits.memory }}
  requests:
    cpu: {{ .Values.template.resources.buildkit.requests.cpu }}
    memory: {{ .Values.template.resources.buildkit.requests.memory }}
{{- end }}

{{/*
Generate step-specific resource configurations
*/}}
{{- define "ci-pipeline-template.verifyTokenResources" -}}
resources:
  {{- toYaml .Values.template.steps.verifyToken.resources | nindent 2 }}
{{- end }}

{{- define "ci-pipeline-template.gitCloneResources" -}}
resources:
  {{- toYaml .Values.template.steps.gitClone.resources | nindent 2 }}
{{- end }}

{{- define "ci-pipeline-template.securityScanResources" -}}
resources:
  {{- toYaml .Values.template.steps.securityScan.resources | nindent 2 }}
{{- end }}

{{- define "ci-pipeline-template.buildkitBuildResources" -}}
resources:
  {{- toYaml .Values.template.steps.buildkitBuild.resources | nindent 2 }}
{{- end }}

{{- define "ci-pipeline-template.runTestsResources" -}}
resources:
  {{- toYaml .Values.template.steps.runTests.resources | nindent 2 }}
{{- end }}

{{- define "ci-pipeline-template.tagLatestResources" -}}
resources:
  {{- toYaml .Values.template.steps.tagLatest.resources | nindent 2 }}
{{- end }}

{{/*
Generate step-specific environment variables
*/}}
{{- define "ci-pipeline-template.buildkitBuildEnv" -}}
{{- if .Values.template.steps.buildkitBuild.env }}
env:
  {{- toYaml .Values.template.steps.buildkitBuild.env | nindent 2 }}
{{- end }}
{{- end }}

{{- define "ci-pipeline-template.runTestsEnv" -}}
{{- if .Values.template.steps.runTests.env }}
env:
  {{- toYaml .Values.template.steps.runTests.env | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Generate step-specific security context
*/}}
{{- define "ci-pipeline-template.buildkitBuildSecurityContext" -}}
{{- if .Values.template.steps.buildkitBuild.securityContext }}
securityContext:
  {{- toYaml .Values.template.steps.buildkitBuild.securityContext | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Generate step-specific readiness probe
*/}}
{{- define "ci-pipeline-template.buildkitBuildReadinessProbe" -}}
{{- if .Values.template.steps.buildkitBuild.readinessProbe }}
readinessProbe:
  {{- toYaml .Values.template.steps.buildkitBuild.readinessProbe | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Generate GitHub username
*/}}
{{- define "ci-pipeline-template.githubUsername" -}}
{{- .Values.github.username }}
{{- end }}

{{/*
Generate GitHub secret name
*/}}
{{- define "ci-pipeline-template.githubSecretName" -}}
{{- .Values.github.secretName }}
{{- end }}

{{/*
Generate workspace volume size
*/}}
{{- define "ci-pipeline-template.workspaceVolumeSize" -}}
{{- .Values.template.volumes.workspace.size }}
{{- end }}

{{/*
Generate buildkit cache volume size
*/}}
{{- define "ci-pipeline-template.buildkitCacheVolumeSize" -}}
{{- .Values.template.volumes.buildkitCache.size }}
{{- end }}

{{/*
Generate timeout configurations
*/}}
{{- define "ci-pipeline-template.timeouts" -}}
activeDeadlineSeconds: {{ .Values.template.timeouts.activeDeadlineSeconds }}
ttlStrategy:
  secondsAfterCompletion: {{ .Values.template.timeouts.ttlAfterCompletion }}
  secondsAfterSuccess: {{ .Values.template.timeouts.ttlAfterSuccess }}
  secondsAfterFailure: {{ .Values.template.timeouts.ttlAfterFailure }}
{{- end }}

{{/*
Generate step-specific image references
*/}}
{{- define "ci-pipeline-template.verifyTokenImage" -}}
{{- .Values.template.steps.verifyToken.image }}
{{- end }}

{{- define "ci-pipeline-template.gitCloneImage" -}}
{{- .Values.template.steps.gitClone.image }}
{{- end }}

{{- define "ci-pipeline-template.securityScanImage" -}}
{{- .Values.template.steps.securityScan.image }}
{{- end }}

{{- define "ci-pipeline-template.buildkitBuildImage" -}}
{{- .Values.template.steps.buildkitBuild.image }}
{{- end }}

{{- define "ci-pipeline-template.tagLatestImage" -}}
{{- .Values.template.steps.tagLatest.image }}
{{- end }}