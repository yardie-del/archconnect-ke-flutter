/// Ported from the Kotlin `ProjectCategory` enum.
enum ProjectCategory {
  housePlan('Residential House Plans'),
  threeDRender('3D Renders & Walkthroughs'),
  countyApproval('County Building Approvals'),
  commercial('Commercial & Office Complexes'),
  interior('Interior Architecture & Fitout'),
  renovation('Renovation & Structural Extension');

  const ProjectCategory(this.displayName);
  final String displayName;
}

/// Ported from the fields the Kotlin `viewModel.postProjectBrief(...)`
/// call takes when a client submits a new brief.
class ProjectBrief {
  const ProjectBrief({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budgetMinKsh,
    required this.budgetMaxKsh,
    required this.deadlineDays,
  });

  final String title;
  final String description;
  final ProjectCategory category;
  final String location;
  final int budgetMinKsh;
  final int budgetMaxKsh;
  final int deadlineDays;
}