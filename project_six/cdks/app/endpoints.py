from fastapi import APIRouter

router = APIRouter(prefix="/data")


@router.get("")
def get_data():
    return {"data": "Data retrieved successfully!"}

@router.post("")
def post_data():
    return {"data": "Data created successfully!"}

@router.put("")
def put_data():
    return {"data": "Data updated successfully!"}

@router.delete("")
def delete_data():
    return {"data": "Data deleted successfully!"}
