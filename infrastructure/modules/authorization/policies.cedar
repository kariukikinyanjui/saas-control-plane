// The "Golden Rule" of Multi-Tenant SaaS
permit (
  principal,
  action,
  resource
)
when {
    // The specific lock: You can only access resources if
    // your badge (tenant_id) matches the building's lock (tenant_id).
    principal.tenant_id == resource.tenant_id
};
