=begin
SUPERSEDE ReleasePlanner API to UI

OpenAPI spec version: 1.0.0

Generated by: https://github.com/swagger-api/swagger-codegen.git

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end
class ReleasesController < ApplicationController
  before_action :set_release, except: [:add_new_release_to_project, :get_releases]

  def add_new_release_to_project
    @release = @project.releases.build(release_params)

    if @release.save
      render json: @release
    else
      render json: @release.errors, status: :unprocessable_entity
    end
  end

  def cancel_last_release_plan
    # Your code here
    @release.plan.destroy
    render json: {"message" => "Plan deleted"}
  end

  def delete_release
    @release.destroy
    render json: {"message" => "Release deleted"}
  end

  def get_release_plan
    # Your code here
    #@plan = FakePlanner.plan(@release, @project)
    if @release.starts_at.nil?
      @plan = FakePlanner.plan(@release)
    else
      @plan = ValentinPlanner.plan(@release)
    end
    render json: @plan
  end

  def get_releases
    @releases = @project.releases

    render json: @releases
  end

  def get_release
    render json: @release
  end

  def modify_release
    if @release.update(release_params)
      render json: @release
    else
      render json: @release.errors, status: :unprocessable_entity
    end
  end

  def add_resources_to_release
    params[:_json].each do |r|
        resource = @project.resources.find_by(id: r[:resource_id])
          if resource and not @release.resources.exists?(id: r[:resource_id])
            @release.resources << resource
          end
      end
    render json: @release
  end

  def delete_resources_from_release
    params[:ResourceId].split(',').each do |i|
        resource = @release.resources.find_by(id: i)
          if resource
            @release.resources.delete(resource)
          end
      end
    render json: @release
  end
  
  def get_release_features
    # Your code here
    @features = @release.features
    render json: @features
  end
  
  def add_features_to_release
    params[:_json].each do |f|
        feature = @project.features.find_by(id: f[:feature_id])
          if feature and not @release.features.exists?(id: f[:feature_id])# and feature.release.nil?
            @release.features << feature
          end
      end
    render json: {"message" => "Done"}
  end

  def remove_features_from_release
    params[:featureId].split(',').each do |i|
        feature = @release.features.find_by(id: i)
          if feature
            @release.features.delete(feature)
          end
      end
    render json: {"message" => "Done"}
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_release
      @release = @project.releases.find(params[:releaseId])
    end

    # Only allow a trusted parameter "white list" through.
    def release_params
      params.require(:release).permit(:name, :description, :starts_at, :deadline)
    end
end
