"""
Requisition Management Tools for Brightwell TA Screening Assistant
"""
from ibm_watsonx_orchestrate.agent_builder.tools import tool
from typing import Dict, List, Optional, Any

# Embedded requisition data - WXO tools cannot access local files
REQUISITION_DATA = [
    {
        "req_id": "REQ-2026-001",
        "title": "Registered Nurse - ICU",
        "department": "Critical Care",
        "status": "open",
        "must_haves": {
            "license": "Active RN license in state",
            "years_experience": "2+ years ICU experience",
            "unit_experience": "ICU or Critical Care",
            "certifications": "BLS, ACLS"
        },
        "nice_to_haves": {
            "additional_certs": "CCRN certification",
            "specialty": "Trauma or cardiac ICU experience",
            "education": "BSN preferred"
        },
        "posted_date": "2026-05-15"
    },
    {
        "req_id": "REQ-2026-002",
        "title": "Medical Assistant - Primary Care",
        "department": "Primary Care",
        "status": "open",
        "must_haves": {
            "certification": "Certified Medical Assistant (CMA) or Registered Medical Assistant (RMA)",
            "years_experience": "1+ years in primary care or family medicine",
            "skills": "Vital signs, EHR documentation, patient intake"
        },
        "nice_to_haves": {
            "ehr_systems": "Epic or Cerner experience",
            "languages": "Bilingual (English/Spanish)",
            "specialty": "Pediatrics or geriatrics experience"
        },
        "posted_date": "2026-05-20"
    },
    {
        "req_id": "REQ-2026-003",
        "title": "Physical Therapist",
        "department": "Rehabilitation Services",
        "status": "open",
        "must_haves": {
            "license": "Active PT license in state",
            "degree": "Doctor of Physical Therapy (DPT)",
            "years_experience": "1+ years clinical experience"
        },
        "nice_to_haves": {
            "specialty": "Orthopedic or sports medicine",
            "certifications": "Board certification in specialty area",
            "experience": "Outpatient clinic experience"
        },
        "posted_date": "2026-05-18"
    },
    {
        "req_id": "REQ-2026-004",
        "title": "Clinical Lab Technician",
        "department": "Laboratory Services",
        "status": "open",
        "must_haves": {
            "certification": "MLT or MLS certification",
            "license": "State clinical lab license",
            "years_experience": "2+ years in clinical laboratory",
            "skills": "Hematology, chemistry, microbiology"
        },
        "nice_to_haves": {
            "specialty": "Blood bank or molecular diagnostics",
            "systems": "LIS experience (Cerner or Epic)",
            "shift": "Willingness to work nights/weekends"
        },
        "posted_date": "2026-05-22"
    },
    {
        "req_id": "REQ-2026-005",
        "title": "Nurse Practitioner - Family Medicine",
        "department": "Primary Care",
        "status": "open",
        "must_haves": {
            "license": "Active NP license with prescriptive authority",
            "certification": "FNP-C or AGPCNP-C certification",
            "years_experience": "2+ years as practicing NP",
            "specialty": "Family medicine or primary care"
        },
        "nice_to_haves": {
            "population": "Pediatric and geriatric experience",
            "procedures": "Minor procedures (suturing, joint injections)",
            "languages": "Bilingual preferred"
        },
        "posted_date": "2026-05-10"
    }
]

@tool
def get_requisition_data(
    req_id: Optional[str] = None,
    department: Optional[str] = None,
    status: Optional[str] = None,
    limit: Optional[int] = None
) -> Dict[str, Any]:
    """Retrieve requisition data with flexible filtering options.
    
    Args:
        req_id: Filter by specific requisition ID
        department: Filter by department name
        status: Filter by status (open, closed, on_hold)
        limit: Maximum number of results to return
    """
    results = REQUISITION_DATA.copy()
    
    if req_id:
        results = [r for r in results if r.get("req_id") == req_id]
    if department:
        results = [r for r in results if department.lower() in r.get("department", "").lower()]
    if status:
        results = [r for r in results if r.get("status") == status]
    if limit and limit > 0:
        results = results[:limit]
    
    return {
        "count": len(results),
        "requisitions": results
    }

@tool
def get_requisition_by_id(req_id: str) -> Dict[str, Any]:
    """Retrieve a single requisition by its unique identifier.
    
    Args:
        req_id: The requisition ID (e.g., REQ-2026-001)
    """
    for req in REQUISITION_DATA:
        if req.get("req_id") == req_id:
            return {
                "found": True,
                "requisition": req
            }
    return {
        "found": False,
        "error": f"Requisition {req_id} not found"
    }

# Made with Bob
